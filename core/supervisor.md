# Supervisor · 三方任务组协议（v0.9.6）

> 把“用户 ↔ 执行 agent”的一对一任务升级为“用户 + 执行 agent + 监督 agent”的三方任务组。
> 监督 agent 可以运行在桌面实时语音、另一个终端或另一个模型中。协议不依赖私有 API，只依赖三个角色可访问同一工作区。

---

## §1 三个角色

| 角色 | 职责 | 不做什么 |
|---|---|---|
| 用户 | 出题、调整优先级、仲裁分歧、最终验收 | 不需要手工搬运两个 agent 的上下文 |
| 执行 agent（worker） | 取数、分析、写 checkpoint 和正式产出 | 不替监工关闭未处理的干预 |
| 监督 agent（supervisor） | 读进度、抽查质量、分级干预、口头汇报、收尾验收 | 不取代 worker 写研究正文，不替用户做最终决策 |

实时语音不是 worker 的问答入口，而是监督 agent 的交互界面。用户可以一边让 worker 干活，一边问监工“做到哪了”“这段可靠吗”“让它重做市场空间”。

## §2 能做到的“实时”边界

- 文件协议是**协作式实时**：worker 在安全点检查监工消息，supervisor 在被会话唤醒后检查 checkpoint。
- 🔴 干预会在 worker 的**下一个安全点**生效，不能中断正在执行中的单次工具调用。
- 安全点包括：外部工具批次前后、每个 H2 段开始前、每次 checkpoint 后、最终归档前。
- 如果宿主支持文件事件、heartbeat 或定时唤醒，可按用户要求启用主动巡检；如果不支持，监工必须明确说明“需要会话被唤醒后巡检”，不能假装在后台持续运行。
- 实时语音关闭不影响任务：所有决定都已落到工作区文件。

## §3 通信总线

### 3.1 新任务默认使用 mailbox 协议（protocol 1.1）

```text
{workspace}/
  .task-pulse
  .checkpoint/{task-id}.md
  .supervision/
    pending-{target-slug}.md              # 可选：监工先启动时的等待请求
    {task-id}.md                         # 监工拥有：人类可读的巡检与验收总账
    {task-id}/
      state.json                         # 监工拥有：游标、状态、巡检节奏
      to-worker/S-{timestamp}.md         # 监工拥有：干预 / 用户口头指令
      to-supervisor/W-{message-id}.md    # worker 拥有：采纳 / 申辩回执
  coverage/... 或 themes/...
```

**单写者规则**：

- supervisor 只能写 `{task-id}.md`、`state.json`、`to-worker/`
- worker 只能写 `to-supervisor/`、checkpoint 和正式产出
- 任何一方都不得改写对方拥有的文件

这个规则用于避免两个会话同时更新一个 Markdown 工单时发生覆盖。

如果 supervisor 先启动且 `.task-pulse` 里还没有目标任务：

1. 不得猜测或占用一个 task-id。
2. 可创建 `.supervision/pending-{target-slug}.md`，记录目标、skill、语音模式和巡检节奏。
3. 目标任务出现后，按真实 task-id 初始化 mailbox，并在 pending 文件写 `resolved_to: {task-id}`。
4. pending 文件只属于 supervisor，worker 不需要读取。

### 3.2 兼容 v0.9.6 早期单文件工单

如果只有 `.supervision/{task-id}.md`、没有同名目录，继续使用旧协议：supervisor 追加干预，worker 在原条目下补回执。

如果同名目录存在，**mailbox 协议优先**；worker 不再编辑 `{task-id}.md`。

## §4 状态与消息格式

### 4.1 `state.json`

```json
{
  "protocol": "1.1",
  "task_id": "task-007",
  "status": "waiting",
  "voice_mode": true,
  "cadence": "checkpoint",
  "last_seen_step": null,
  "last_checked_at": null
}
```

`status` 只使用：

- `waiting`：目标任务尚未出现在 `.task-pulse`
- `watching`：正在监督
- `needs_user`：有分歧等待用户仲裁
- `done`：监工总结已完成

### 4.2 supervisor → worker

文件名使用 `S-{UTC 时间}-{短随机串}.md`，确保并发时不重名。

```markdown
# 监工消息 · S-20260728T120000Z-a1b2

- source: supervisor | user_voice
- severity: red | yellow | green
- target: §5 市场空间
- created_at: 2026-07-28T12:00:00Z
- problem: 800G 出货量没有来源
- basis: core/evidence.md · 使用原则 1
- request: 补官方来源；拿不到则改为待核验假设并降低结论强度
```

### 4.3 worker → supervisor

回复文件名使用 `W-{原 message-id}.md`：

```markdown
# Worker 回执 · S-20260728T120000Z-a1b2

- decision: accepted | disputed
- updated_at: 2026-07-28T12:03:00Z
- changed: themes/ai-capex/2026-07-28-industry.md · §5
- response: 已补官方口径并重写该结论
- evidence: Microsoft FY26 Q3 transcript
```

`disputed` 必须说明理由。supervisor 可以接受申辩，也可以把双方观点压缩成一条待用户裁决事项，但不得和 worker 往返争论超过一轮。

## §5 干预分级

| 级别 | 使用场景 | worker 义务 | 语音行为 |
|---|---|---|---|
| 🔴 red | 编数字、方向性错误、合规红线、用户要求暂停 | 到下一个安全点先处理，再继续 | 立即播报 |
| 🟡 yellow | 证据等级缺失、结构漏段、口径不一致 | 下一段开始前处理 | 段间播报 |
| 🟢 green | 表达或结构优化，不影响正确性 | 收尾统一回应 | 默认不打扰 |

每轮最多 3 条干预。每条都必须指向具体段落并引用 `acceptance.md`、`evidence.md`、`compliance.md` 或目标 skill 的明确要求。

用户口头指令的权威级别最高，但严重度仍按紧急程度选择；如果用户指令与合规或事实纪律冲突，worker 应写 `disputed` 并交用户确认，不得静默执行。

## §6 worker 侧义务

1. 在 preamble 创建 task-id 后，检查单文件工单和 mailbox 目录；命中则在 `[Preflight]` 写 `监督：on`。
2. 在每个安全点读取尚无对应 `W-*.md` 的 `to-worker/` 消息。
3. 按 red → yellow → green 顺序处理，并在 `to-supervisor/` 写独立回执。
4. 处理 red / yellow 后再进入下一段；green 可在收尾统一处理。
5. 监工在任务中途接入也必须生效，因此不能只在任务启动时检查一次。
6. 最终归档前确认没有未回执的 red / yellow 消息。

没有监督工单时，一切照旧，零额外流程。

## §7 supervisor 巡检循环

每次被唤醒后：

1. 读 `.task-pulse`，确认任务是否存在、当前 step 是否变化。
2. 读 `.checkpoint/{task-id}.md` 的新增部分和正式产出草稿。
3. 读 `to-supervisor/`，关闭已采纳事项或整理申辩。
4. 对新增内容检查：
   - 数字：抽 2-3 个关键数字，查证据标签和来源
   - 结构：对照目标 skill 的必需段落
   - 一致性：量价、可比池、时间口径、隐含份额
   - 反套话：风险是否可观测，壁垒是否有量化锚
   - 合规：评级、目标价、收益承诺、非公开信息包装
5. 有问题才写新消息；无问题只更新 `state.json` 游标与总账巡检时间。
6. `.task-pulse` 中任务消失后，结合 `active-tasks.md` 和归档结果判断是 done、abandoned 还是异常丢失，不能仅凭“消失”宣布通过。

## §8 实时语音交互

### 接入时

用不超过 20 秒的口头简报说明：

> “监工已接入 task-007，worker 正在做 AI CapEx 行业框架，目前 4/10。默认每个 checkpoint 巡检；红色问题立即提醒你，黄色问题段间汇报。”

### 用户可以直接说

- “现在做到哪了？”→ 读 `.task-pulse` + checkpoint，口头汇报进度和当前段。
- “刚才那段可靠吗？”→ 对最新段做一次定向数字与证据抽查。
- “让它把估值那段重做。”→ 写 `source: user_voice` 的标准消息。
- “先别打断，只记问题。”→ 后续非合规问题降为 green；合规红线仍必须 red。
- “暂停它。”→ 写 red 暂停消息，并明确“会在 worker 下一个安全点生效”。
- “有什么需要我裁决？”→ 汇总 `needs_user` 项，只讲分歧和后果。

### 默认保持安静

只有以下情况主动说话：red、yellow 到达段间、需要用户仲裁、任务完成。没有问题时不反复播报“正常”。

## §9 收尾

任务完成后，supervisor：

1. 按 `acceptance.md` 通用清单 + 目标 skill 专属清单逐项验收。
2. 把所有消息与回执状态汇总到 `.supervision/{task-id}.md`。
3. 更新 `state.json`：`status: done`。
4. 在语音和文字中给出同一结论：通过 / 有条件通过 / 不通过。
5. 保留 `.supervision/` 全部记录，不随 checkpoint 删除。

监工总结格式：

```markdown
## 监工总结 · {ISO 时间}

验收：
- [x/ ] {通用 + 专属清单}

干预统计：🔴 {n} 条（采纳 {n}）· 🟡 {n} 条（采纳 {n}）· 🟢 {n} 条 · 待用户裁决 {n} 条

遗留问题：{未解决项，或“无”}

监工结论：{通过 / 有条件通过 / 不通过}
```

## §10 启动方式

```text
任务 A（执行）：
  “用 sm-company-deepdive 深度看 300308。”

任务 B（实时语音监工，同一工作区）：
  “用 sm-supervisor 监工 300308 的 deepdive，开启语音模式。”
```

顺序无所谓。监工先开时创建 pending 请求并等待真实 task-id；worker 先开时从当前 checkpoint 接入。最稳妥的体验是两个任务共享同一工作区，但各自只写自己拥有的文件。
