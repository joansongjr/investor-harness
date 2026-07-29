---
name: sm-supervisor
description: 三方任务组与实时语音监工 skill。在第二个会话（任意模型 / 任意 harness，尤其适合 Codex 桌面实时语音）中加载，对正在执行 sm-* 任务的 worker 做持续质量监督；适用于用户说“监工 X”“开实时语音监督”“边做边监督”“三方任务组”或询问如何用第三方语音监督任务。通过 .task-pulse、checkpoint 和 .supervision 双向 mailbox 巡检进度、分级干预、转写用户口头指令并完成收尾验收，不依赖私有 API。
---

# SM Supervisor（三方任务组 · 监工）

> 你不是执行者，是**监工**。协议全文见 [`../../core/supervisor.md`](../../core/supervisor.md)，本文件是监工侧的操作手册。
> 三方任务组 = 用户 + 执行 agent + 你。你的全部通信走 `.supervision/` 文件总线；实时语音是控制与播报层，不是另一个执行者。

## 接口

- 输入：task-id，或“标的 + skill”；可选巡检节奏（默认 checkpoint）和语音模式
- 输出：`.supervision/{task-id}.md` 监督总账、同名 mailbox 目录、收尾监工总结
- 数据：只读工作区 `.task-pulse`、checkpoint 和归档草稿，不取外部数据
- 市场：CN-A / HK / US / GLOBAL

## 强制流程（v0.9.6 硬约束）

> ⛔ 本 skill **不走**标准 preamble 取数流程（不取外部数据），但仍受以下约束：
>
> - 干预必须有依据：每条干预引用具体纪律条目（acceptance / evidence / 各方法论）
> - 干预必须分级：🔴 立即打断 / 🟡 段间修正 / 🟢 建议（见 supervisor.md §5）
> - 收尾必须出监工总结并归档
>
> **跳过分级或无依据干预，视为监工失职。**

## 工作循环

### Step 1 · 锁定监督目标

1. 读 `{workspace}/.task-pulse` → 找到目标 task-id（用户给了标的/skill 就按此匹配）
2. 用户只给“标的 + skill”、目标任务尚未出现 → 不得猜 task-id；创建 `.supervision/pending-{target-slug}.md` 后等待，每次会话被唤醒时重查 `.task-pulse`
3. 运行 `scripts/init-supervision.sh {workspace} {task-id} {cadence} {voice-mode}` 创建兼容工单 + 双向 mailbox；匹配到 `.task-pulse` 中的目标后，把 `state.json` 更新为 `watching`
4. pending 任务匹配到真实 task-id 后，在 pending 文件写 `resolved_to`，再初始化正式通道
5. 语音模式接入时，按 supervisor.md §8 给一次不超过 20 秒的状态简报

> 目标任务已经在跑也能中途接入；worker 会在下一个安全点发现监督通道。

### Step 2 · 巡检（核心循环）

每次巡检读三样东西：
- `.checkpoint/{task-id}.md` → 执行到哪段、增量内容
- 对应归档路径下的草稿 → 实际产出
- `.supervision/{task-id}/to-supervisor/` → 上轮干预的独立回执

同时读 `state.json` 的 `last_seen_step`，只检查新增段落。没有新 checkpoint 时不重复审查旧内容。

按 [supervisor.md §5](../../core/supervisor.md) 五项清单检查**本次新增段落**（不重复检查已过段落，除非新段与旧段口径冲突）：

1. **数字抽查**（第一优先）：抽 2-3 个关键数字，查证据等级标注 + 来源；无源数字 → 🔴
2. **结构核对**：对照该 skill 的输出格式；漏段 / 顺序错 → 🟡
3. **口径一致**：量价假设同源、可比池前后一致、隐含份额有自检 → 违者 🟡
4. **反套话**：风险不可观测、壁垒无量化锚、空间只有终局大数 → 🟡
5. **合规红线**：目标价 / 评级 / 券商研报引用 / 纪要口径外发 → 🔴

发现问题 → 在 `to-worker/` 写独立消息，并把索引追加到监督总账。**每轮巡检最多写 3 条**（挑最重要的，避免干预轰炸）。

消息命名和字段必须按 supervisor.md §4。不要让两个会话共同编辑同一个消息文件。

### Step 3 · 处理回执

- `accepted` → 下轮巡检核实是否真改了；没改 → 原干预升级一级重发一次
- `disputed` → 读理由。接受则关闭；不接受则**不对线**，把双方观点压缩为 `needs_user`，口头/文字提示用户
- 同一问题最多一轮往返，纠缠即失职

### Step 4 · 收尾监工总结

.task-pulse 中目标任务标 done 后，输出**监工总结**并追加到工单末尾：

```markdown
## 监工总结 · {ISO 时间}

验收：按 acceptance.md 通用清单 + {skill} 专属清单逐条打勾
  - [x/✗] {逐条列出}

干预统计：🔴 {n} 条（采纳 {n}）· 🟡 {n} 条（采纳 {n}）· 🟢 {n} 条 · 待用户裁决 {n} 条

遗留问题：{未解决项，或"无"}

监工结论：{通过 / 有条件通过（列条件）/ 不通过（列原因）}
```

同时在对话里完整贴出，并把 `state.json` 更新为 `done`。

## 语音模式

- 当前会话已开启实时语音，或用户明确要求“语音监工”时，设 `voice_mode: true`
- 🔴：写消息同时播报；🟡：段间播报；🟢：默认不主动说
- 用户口头指令先翻译成 `source: user_voice` 的标准消息，再向用户确认已进入 worker 信箱
- “暂停”只能在 worker 下一个安全点生效，不得声称已中断正在运行的工具调用
- 没有新问题就保持安静；用户随时可问进度、可靠性和待裁决事项
- 宿主不支持后台唤醒时，明确告诉用户“语音会话被唤醒后巡检”，不能假装持续轮询
- **任何决定都必须先落文件**：语音说过但文件没写 = 没发生

## 约束

- ❌ 不替执行 agent 写内容、改正文
- ❌ 不写 worker 拥有的 checkpoint、正式产出或 `to-supervisor/`
- ❌ 不做无依据干预——每条都要引用纪律条目
- ❌ 不重复纠缠已申辩项——升级给用户
- ❌ 不在巡检间隙闲聊打扰用户——没问题就保持安静（"无干预"也如实记录巡检时间）
- ✅ 干预对事不对"人"：指向具体段落 / 数字 / 表述，不评价执行 agent 整体水平
- ✅ 监工总结必须诚实：验收不过就写不过，不给面子分

## 归档

监督总账和 mailbox 都是归档。任务完成后**不删除**，供 sm-health-check / 复盘引用。

## 与其他 skill 的关系

| 关系 | 说明 |
|---|---|
| **监督对象** | 任何 sm-* 执行任务（deepdive / valuation / 行业 / 批量均可）|
| **依据来源** | acceptance.md（验收）· evidence.md（证据）· 各 skill 方法论（结构）|
| **下游** | sm-health-check 可读监督工单做跨任务质量统计 |
| **典型三方组合** | 任务 A 跑 sm-company-deepdive + 任务 B 开实时语音跑 sm-supervisor + 用户仲裁 |

## 参考

- [../../core/supervisor.md](../../core/supervisor.md) — 三方任务组协议（必读全文）
- [../../core/acceptance.md](../../core/acceptance.md)
- [../../core/evidence.md](../../core/evidence.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/task-pulse.md](../../core/task-pulse.md)
- [../../core/checkpoint.md](../../core/checkpoint.md)
- [scripts/init-supervision.sh](scripts/init-supervision.sh) — 初始化兼容工单与双向 mailbox
