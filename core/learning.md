# Learning · 提问驱动自主学习协议（v0.9.7）

> 本文件是学习机制的**唯一规范源（single source of truth）**——数据契约、阈值、自动化边界全部以本文件为准；
> `skills/sm-learn/SKILL.md` 是归纳侧操作手册，preamble Step 0.7 / postamble Step 5.5 是执行挂载点，三者与本文件冲突时以本文件为准。
> Tier 2 文档：只在跑 sm-learn、排查学习行为、或用户问"学了什么"时加载。

---

## §0 定位：它自主运行，用户只保留否决权

**要解决的问题**：用户反复用同样的角度提问（做模型总问那几个假设、复盘总问那几类归因、深度报告总补问客户集中度），每次都要重新说一遍。学习机制把这些**问法**归纳成规则，反补进对应 skill 的必答问题 / 输出段里——下次 skill 自己就先答了。

**自主运行契约（核心设计，区别于一切"提案-审批"式设计）**：

1. **采集自动**：每次 skill 会话的 postamble 静默落账，不打断任务、不请示
2. **归纳自动**：每积累 3-5 次 skill 会话（默认 4 次触发、5 次强制）自动跑一轮归纳，不需要用户说任何话
3. **生效自动**：过全部硬门槛（阈值 + 泛化 + 三重冲突检查）的候选**直接写入试用期**，每轮上限 3 条；会话尾一行摘要告知
4. **验证自动**：试用期信号自动跟踪，失败规则自动停用（suspended，可一键恢复）
5. **用户只保留否决权**：任何时刻说"撤销 L-xxx"即回滚；说"看看学了什么"即审计。**沉默 = 放行，不是同意书**——所以一切自动写入都必须可逆、可追溯、留在 workspace 内

**仅三类候选仍走人工裁决**（自动通道处理不了的）：
- C4 新场景 skill 建议（要建新文件结构，影响面大）
- 修订案（新候选与现行规则矛盾，机器不该替用户选边）
- 与用户本地规范冲突的候选（本地规范 > 学习规则，冲突只能由用户裁）

**四段闭环**：采集（postamble）→ 归纳（自动触发的 sm-learn）→ 写回（自动，workspace 内）→ 验证（试用期）。

**问题回家原则**：每个问题按**内容**归属到它所属的 skill（`home` 字段），而不是按它发生在哪个会话。跑 deepdive 时问"这个折旧假设是不是太乐观"→ home = `model-check`；问"今天为什么跌"→ home = `close-recap`。归纳按 home 分组，反补落到 home skill 的 overlay。

---

## §1 数据契约（normative schema）

### 1.1 question-ledger.jsonl

位置 `{workspace_root}/.learning/question-ledger.jsonl`。JSONL、一行一事件、**append-only**（`printf '%s\n' '{json}' >> …`，⛔ 严禁读全文再回写）。null 字段直接省略。目标 < 30 KB，最大 128 KB，超限由 sm-learn 把 cursor 之前的行滚入 `archive/question-ledger-YYYYMM.jsonl`。

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `v` | number | ✅ | schema 版本，当前 `1` |
| `id` | string | ✅ | `{session}.{seq}`，全局唯一。**cursor、台账出处、防重提全部指向 id，不用行号**（归档会移行，行号不可靠） |
| `ts` | string | ✅ | ISO 8601 到分钟 |
| `session` | string | ✅ | `{MMDD}{4位hex}`，会话首次写入生成 |
| `task` | string | 可选 | `t-NNN`，回链 .task-pulse |
| `skill` | string | ✅ | **会话 skill**（本次跑的是哪个），output-archive 简称；散聊 `none` |
| `home` | string | ✅ | **归属 skill**（问题内容属于谁）。默认 = skill；内容明显属于另一 skill 时按 keyword-routes 语义改判；无从归属 = `none`（C4 池） |
| `target` | string | 可选 | `{ticker}_{name}` 或 theme-slug。批量会话按事件所指标的填，同一问法对多标的出现 → **每标的一行**（见 §2.4） |
| `scene` | enum | ✅ | `外发` / `内部` / `讨论`。从任务类型推断：点评/深度/PPT 终稿 = 外发；PM brief/晨会 = 内部；摸底/闲聊/预期差扫描 = 讨论。**纠正的适用范围默认锁定在其发生的 scene**（防"报告层纠正污染讨论层"） |
| `type` | enum | ✅ | `question` / `follow-up` / `correction` / `redirect` / `approval` |
| `sub` | enum | correction 必填 | `fmt`（格式）/ `src`（数据源）/ `method`（方法论）/ `evid`（证据等级）/ `other` |
| `src` | enum | 可选 | 缺省 `live` / `mentor`（老师问题导入）/ `manual`（"把这条记下来"）/ `supervisor`（监督裁决转来） |
| `apr` | enum | approval 必填 | `weak`（指向具体产出："这个表不错"）/ `strong`（含泛化词："以后都这样"） |
| `raw` | string | ✅ | ≤50 字关键句（mentor ≤100 字）。**含指代词（这/那/上次/又/还是）的必须先解引用再落**——写实义内容（"§市场空间又只给总量未拆分"）而非原话字面；无法解引用 → 不入池，learn-state 记 `skipped` +1 |
| `norm` | string | 可选 | ≤30 字抽象问法，三关不过则省略（raw 兜底，归纳时离线二次归一）。规则见 §2.2 |
| `section` | string | 可选 | **段名不用 § 编号**（"市场空间"不是"§5"）——主库重编号后仍能聚拢 |
| `disp` | enum | ✅ | `answered`（当场已答）/ `revised`（按纠正返工完成）/ `partial`（部分处理）/ `deferred`（留待后续）/ `declined`（因硬约束未执行） |
| `mrule` | string | 可选 | 命中试用规则时填 `L-xxx`（recurrence 信号源） |
| `note` | string | 可选 | ≤20 字 |

### 1.2 .learning/ 目录

```
{workspace_root}/.learning/
├── .gitignore              # "*"——本目录永不进任何 git repo
├── question-ledger.jsonl   # 事件总账（postamble 写）
├── learn-state.json        # 计数器 + cursor + 受控词表 + trial 缓存
├── learned-rules.md        # 全局规则（preamble Step 0.7 加载）★ 不放入口 MD
├── adopted-rules.md        # 台账（single source of truth，sm-learn 写）
├── rejected.md             # 拒绝/停用/观察池台账（防重提）
├── trial-log.md            # 试用期三信号记录（postamble append）
├── mentor-imports/         # 导入原文存档（条件从句可回查）
└── archive/                # 滚动归档
```

**全局规则放 `.learning/learned-rules.md` 而不放入口 MD 受管块**，理由：① 自主写入永不出 workspace（写 `~/.claude/CLAUDE.md` 这类用户全局文件必须人工同意，与自主运行矛盾）；② 全局规则只在 skill 执行时才需要生效，而 skill 执行必过 preamble——Step 0.7 加载等价于 Tier 0 注入；③ update.sh / 多 harness / ONBOARDING 零耦合。

### 1.3 learn-state.json

```json
{"v":1,"ts":null,"sessions":0,"events":0,"skipped":0,"dropped":0,
 "cursor":null,"last_learn":null,"learn_count":0,
 "vocab":[],"carryover":[],"watch":[]}
```

- `sessions`/`events`：距上次归纳的增量计数（postamble 递增，sm-learn 清零）
- `cursor`：**最后处理的事件 id**（不是行号）
- `vocab`：受控意图短语词表（§3.2，closed set，只允许 sm-learn 新增）
- `watch`：观察池（未达阈值的簇指纹 + 计数）
- `learn_count`：累计归纳轮数（每第 3 轮触发规则两两一致性扫描，§6.3）
- 双写者：postamble 只递增 `sessions`/`events`/`skipped`/`dropped`，其余字段 sm-learn 独占；ts 乐观锁；解析失败 → 警告不删除

---

## §2 采集（postamble Step 5.5 的规则细节）

### 2.1 采什么、不采什么

**五类硬排除**：机制操作指令（"继续 t-xxx"/路由触发词本身）· 纯数据查询（"NVDA 收盘价"）· 闲聊寒暄 · 会话过程管理（"等一下"/"分段发"）· 买卖决策与仓位表述（⛔ 合规 + 隐私）。粘贴材料本身不采；raw 不录材料原文 / 仓位 / 个人信息。

**试金石**："这句话换一个标的，对未来的分析仍有指导意义吗？"是 → 采。

**type 歧义时优先序**：correction > redirect > follow-up > question。approval 独立判定，分 `weak`（指向具体产出即采）/ `strong`（含泛化词）两档——weak 的用途是阻断对同段的降权提案（§3.4 C3），strong 才作为规则转正佐证。

### 2.2 norm 归一化（三步三关）

受控占位符 10 个：`{公司}` `{竞对}` `{客户}` `{供应商}` `{产品}` `{业务}` `{地区}` `{财期}` `{指标}` `{N}`。

三步：① 槽位替换（具体名词→占位符）；② 保留分析骨架（动作动词 + 分析对象 + 期望输出形态）；③ 措辞对齐 `## 必答问题` 风格（不带问号的问句 + 括号量化口径）。

三关自检（任一不过 → 省略 norm，raw 兜底）：换标的成立 / 无具体名词残留 / 骨架完整。

### 2.3 写入时机：checkpoint 搭车 + 收尾查漏

**每次写 .checkpoint 时**（本来就是分段动作）顺手把该段新发生的可采事件先行落 ledger——长会话的早期纠正不因 context 压缩丢失；**会话收尾**只做查漏与去重（按 session+seq 幂等）。跨会话续跑的任务恢复时不重扫旧段。

### 2.4 数量纪律（配额制，不是纯优先级）

- 默认每会话 ≤3 条，硬上限 5 条
- 超限取舍时**至少保留 1 个问法类（question/follow-up）名额**——纯按 correction 优先会饿死 C1 主打功能
- 观察池中已有 ≥2 次记录的指纹再次命中 → 最高优先级入账（临门一脚不被挤掉）
- 被丢弃的候选在 learn-state 记 `dropped` +1，归纳报告披露"计数是下界"
- **批量 skill 豁免**（batch-refresh / batch-earnings / stock-screen）：同一问法对多标的出现 → 每标的一行（`(session,target)` 对去重，不按 session 去重）——批量会话里"5 家都缺客户集中度"是最强的跨标的证据，不能压成 1 次

### 2.5 token 成本（诚实两档）

典型会话（0-2 条事件、0-2 条 trial 规则在场）≤200 tokens；满载（5 条事件 + 5 条 trial 规则三信号判定）≤600 tokens。trial 判定只做**本会话作用域内**的规则（同 home 的 overlay 规则 + 全局规则，正常 ≤5 条），先关键词粗筛再语义判断。

---

## §3 归纳（自动触发的 sm-learn 运行规则）

### 3.1 触发（自主，无需用户提示）

postamble Step 5.5 末尾检查：`sessions ≥ 4` 或 `events ≥ 15` → **本会话收尾时自动追加执行一轮归纳**（内联，不另开会话）；`sessions = 5` 仍未跑过 → 强制执行。单轮自动归纳最多处理 50 条增量事件（超出 carryover 到下轮）。用户手动触发（"归纳提问"/"跑 sm-learn"）随时可用，无阈值限制。

### 3.2 聚类（两遍 + 受控词表）

指纹 = `{home}::{section 或 "-"}::{意图短语}`。

- **意图短语来自受控词表**（learn-state.vocab，closed set）：聚类时优先复用已有短语；确需新增 → 先对词表全部既有短语跑**双向满足测试**（同一条规则能否同时消解两个诉求）确认非等价，才允许入表。这是防"同一诉求两个月两个指纹"的关键
- **第一遍 within-home**：home 相同 + 双向满足测试 + section 相同或语义相邻 → 同簇
- **第二遍 cross-home 合并**：对第一遍的簇候选忽略 home 维度再跑双向满足测试，能合并的合并；阈值按合并后并集计数。**落点按最终簇的 home 跨度定**：1 个 → 该 skill overlay；≥2 → 全局 learned-rules。（没有这一遍，"盈利预测要量价拆分"在 deepdive×2 + earnings-preview×1 + thesis×1 会被切成三个不达标小簇——最通用的偏好反而永远学不到）
- **窗口**：只聚滚动 90 天内的事件（更早的自动归档，指纹索引保留）；证据强度 = 次数 × 标的数 × **近因因子**（最近一次距今衰减），不奖励时间跨度

### 3.3 阈值（AND）

≥3 次 · ≥2 个标的（批量会话内 (session,target) 计数可满足）· ≥2 个不同自然日 · 标的替换测试通过。

**标的替换测试三档输出**：换任意覆盖池标的成立 → 全局候选；只换同板块标的成立 → **板块条件规则**（规则文本强制带"仅适用于{板块}标的"从句）；都不成立 → 单标的，落 `coverage/{ticker}_{name}/questions.md`。

**事件窗标记**：簇内证据全部落在同一 10 日窗内 → 标"疑似事件驱动"，不直接成案，转条件规则候选（触发条件 = 财报期/异动日/公告事件）或留观察池等跨窗（>30 天）复现。

**scene 锁定**：纠正类候选的规则文本默认带其发生 scene 的适用从句（"做外发点评时…"），无条件版本不允许自动成案——报告层纠正不得污染讨论层（用户工作区明文规定讨论层广撒网）。

### 3.4 四类候选

- **C1 必答问题新增**（问法池）：附加判据——≥2 次的事件 `type ∈ {follow-up, correction}` 或 `disp ∈ {partial, deferred}`（即不是被当次输出提前满足的）。**"经常问"≠"每次都要"**：簇内证据若共享可识别触发语境（异动日/财报期/公告）→ 成案形态为**条件必答**（"当{触发条件}时必答"）而非无条件必答。落点 = home skill overlay 的 `## 必答问题（新增）`
- **C2 偏好规则**（纠正池）：可观测行为句（"做 {skill} 的 {段} 时，必须 {具体动作}"），⛔ 禁止画像句。单 skill → overlay；跨 skill（第二遍聚类合并后）→ 全局 learned-rules
- **C3 段落降权**（redirect 簇）：双闸门——① 至少 1 条显式跳过事件（沉默不是信号）；② 佐证池无同段 approval（**weak 即可阻断**）。**会话模式条件化**：redirect 几乎总是"此刻不要"而非"永远不要"——降权规则默认条件化为"快看类任务（hourly-watch/close-recap/tape-review）中压缩 {段}"，无条件降权仅当证据横跨快看态与深耕态（deepdive/thesis）时才允许，且只走人工裁决通道。降权 ≠ 删段：只允许"压缩至 ≤N 字"或"移附录"。⛔ 永不降权：仍需补的资料 / 合规声明 / 证据等级
- **C4 新场景 skill 建议**（home=none 池）：≥3 次 · ≥2 场景实例 · ≥2 天 + 可写出 ≥3 段输出结构草案 → 提 L3 骨架建议。**只走人工裁决通道**

### 3.5 seen-diff（防重提，在阈值过滤之前）

seen 集 = adopted（全状态）∪ rejected ∪ suspended ∪ blocked ∪ 归档指纹索引。**比对方式：候选簇 vs 台账全量条目逐对语义比对**（台账每条保留 2-3 条代表性 raw 作锚样本；30 条量级成本可控），不做指纹字符串比对（自由文本跨月不可再现）。

分支：
- 命中 adopted-active/trial → 略过成案，新事件转记该规则的 recurrence 观测（喂验证层）
- 命中 rejected（用户明拒）→ 重提门槛 = 裁决日后 ≥6 次 · ≥3 标的 · ≥3 天，重提必须显式披露拒绝历史
- 命中 suspended / 管护性退役（低频/腾位/上游化，**非用户明拒**）→ ledger 复现 1 次即主动提示"说'恢复 L-xxx'一键重建（免重新计数）"——用户没拒绝过的东西不设翻案税
- 命中 blocked（硬约束冲突）→ 永久略过

### 3.6 三重冲突检查（自动成案的最后闸门）

1. **硬约束冲突**（§7 清单）→ 丢弃 + 台账 blocked + 摘要说明一句
2. **与现行规则矛盾** → 不自动成案，出修订案走人工裁决；台账每条规则记录采纳时核对过的本地规范文件路径 + mtime，规范文件变更后 sm-learn 对引用它的规则重跑检查
3. **与本地规范冲突**（preamble Step 2.0 口径：本地规范 > harness > 学习规则）→ 不成案，转提醒项走人工通道。fmt/src 类候选必须逐文件核对本地方法论对应章节，不是泛泛"对照本地规范"

### 3.7 自动生效

过全部闸门的候选按证据强度取**前 3 条**直接写回（§4），状态 `trial`，`auto: true`；其余入观察池。会话尾摘要（对话可见，一条一行）：

```
🧠 自主学习（第 {n} 轮）：归纳 {k} 簇 → 自动生效 {m} 条试用规则
   L-2026-08-05-01 [deepdive] 必答+1：前五大客户收入占比与两期变化（证据 4 次·3 标的）
   L-2026-08-05-02 [全局] 盈利预测必须量价拆分（证据 5 次·跨 3 skill）
   撤销任一条：说"撤销 L-xxx" · 全部审计：说"看看学了什么"
   {待人工裁决 {j} 条（修订案/新 skill 建议），说"看提案"展开}
```

---

## §4 写回（三层，全部在 workspace 内）

### 4.1 层与所有权

| 层 | 载体 | 加载 | 试用期 |
|---|---|---|---|
| skill 问法 overlay | `user-skills/overlays/{skill}.overlay.md` | preamble Step 0.7（随 skill 调用） | 5 次 |
| 全局规则 | `.learning/learned-rules.md` | preamble Step 0.7（每次 skill 调用） | 5 次（任意 skill 计数） |
| 标的专属问题 | `coverage/{ticker}_{name}/questions.md` | preamble Step 2.1 查归档时顺带 | 免试用直接转正 |

台账 `adopted-rules.md` 是 single source of truth，任何载体丢失以台账重建（"重建 learned-rules"）。一条规则只落一层。板块/场景/模式条件不单设物理层——写进规则文本的**适用条件从句**，preamble 0.7 按当次任务属性过滤生效。

### 4.2 overlay 格式

frontmatter：`overlay_of` / `v` / `updated` / `rules[]`（id / status / auto / trial_started；计数权威在 trial-log，frontmatter 只是缓存）。正文三个固定 H2 锚点，每条末尾标 `〔L-xxx〕`：

- `## 必答问题（新增）`——追加到主库该段末尾；主库无此段 → 新建。条目格式与主库必答问题完全一致
- `## 输出段（新增）`——`- 新增段：{段名}（插入位置：{主库段名} 之后；内容要求：{可观测}）〔L-xxx〕`；**锚点用段名不用 § 编号**；找不到锚点 → 尾插并注明
- `## 降权段`——`- 降权：{段名} → 压缩至 ≤{N} 字 | 移附录（适用条件：{快看类任务}）〔L-xxx〕`

大小 ≤1000 字符/文件；⛔ overlay 只能增与降权，**不得删除或替换主库任何必答问题与必需段**——违规条目不生效并输出警告。

### 4.3 learned-rules.md 格式

```markdown
# Learned Rules · 全局规则（sm-learn 自动维护 · preamble Step 0.7 加载）

> ⛔ 本文件规则不可覆盖：证据分级 / 合规 / 数据源纪律 / preamble·postamble 步骤。
> 冲突裁决：适用条件越窄越优先（ticker-questions > 条件规则 > overlay > 本文件无条件规则）。

| ID | 规则（可观测行为 + 适用条件） | 出处 | 生效 | 状态 |
|---|---|---|---|---|
| L-2026-08-05-02 | 任何盈利预测必须量价拆分并单独标注价的假设来源 | 5 次·跨 3 skill | 2026-08-05 | 试用中(auto) |
```

上限 ≤30 条 / ≤2000 字符（`wc -m` 口径，多 harness 通用）。

### 4.4 台账与撤销

`adopted-rules.md` 每条：ID / status（trial·adopted·extended·suspended·retired）/ auto / rule / layer / write_target / home / scope（global·sector·ticker·conditional）/ norm 锚 + 2-3 条 raw 锚样本 / source_events（**事件 id 列表**，不是行号）/ checked_norms（本地规范路径+mtime）/ adopted / decided / retire_reason（user-revoked·low-freq·cap-eviction·upstreamed·trial-failed）。

**撤销**（"撤销 L-xxx"）：定位 → 按层移除全部 `〔L-xxx〕` 条目 → 台账迁 retired（user-revoked）→ trial-log 记 closed → 对话交代移除路径 + "恢复 L-xxx 可重建" → grep 验证零残留。幂等。
**恢复**（"恢复 L-xxx"）：从台账原文重建到原落点，重新进入试用期。

---

## §5 验证（试用期，自动）

### 5.1 三信号（postamble 对本会话作用域内 trial 规则逐条判，append 到 trial-log.md）

| 信号 | 判定 | 备注 |
|---|---|---|
| `satisfied` | 输出是否包含规则要求的可观测行为，**按规则文本内可量化子项打分**（表的期数/是否给区间），不打整体印象分 | 数据缺失但已明写并入"仍需补的资料" = yes；规则场景未触发 = n-a（不计入用次） |
| `recurrence` | 用户是否又问了该规则对应问法 | **只统计规则有出场机会的会话**（同 home 会话且场景实际触发）；`home=none` 闲聊里的重问不计。**recurring-by-nature 规则**（norm 含 {财期} 槽位或绑定数据更新节律）改判"输出是否已含最新期数据"，重问新数据不算失败 |
| `ignored` | 规则新增段被明确忽略/要求删掉（同步落 redirect 事件 + mrule 关联） | 转正后继续累计（见 5.3） |

### 5.2 结局（sm-learn 归纳轮顺带结算）

| 结局 | 判据 | 动作 |
|---|---|---|
| 转正 | 5 次中 recurrence=0 且 satisfied ≥4 且 ignored ≤1 | 结算前一句话 spot-check（"L-xxx 新增的 {段} 你在用吗？"，**非阻塞**）：明确否定 → 延长观察；无回复 → **低置信转正**（标 low-confidence，进抽检通道） |
| 自动停用 | recurrence ≥2（含出场机会过滤后）或 ignored ≥3 | **自动转 suspended**（从载体移除、台账保留），摘要告知"说'恢复 L-xxx'可复活"；mentor 规则例外：先自动改写 1 次再走停用 |
| 延长观察 | 样本不足 / recurrence 恰 1 | 重开一轮 5 次；**轮次只按实际使用次数计，日历到期不消耗轮次**；最多 1 轮 |
| 低频转正 | 90 天到期且使用 <5 次且零负面信号（recurrence=0 且 ignored=0） | 直接低置信转正——样本不足 ≠ 信号为负。月频以下 skill（deck-builder 等）的规则比照 ticker 层：免试用直接低置信转正 |

### 5.3 转正后抽检（防"一转正即不可证伪"）

低置信转正的规则每第 5 次使用在 trial-log 补一行利用度记录；ignored/redirect 关联事件转正后继续累计，累计 ≥3 → 自动停用提案。90 天退役判据中"无触发记录"明确定义 = **该 home skill 会话中规则适用场景出现的次数为 0**（不是 ledger 无事件——成功规则恰恰不再产生事件）。

---

## §6 上限与治理

### 6.1 硬上限

全局 learned-rules ≤30 条 / ≤2000 字符；单 overlay ≤1000 字符；单标的 questions.md ≤20 条；**单 skill 并发 trial ≤5 条**（mentor 批量导入也受此限，超出排队）；单轮自动生效 ≤3 条。

### 6.2 超限流程

写回前必测；将超限 → 冻结写入，自动生成合并/退役案（优先级：trial 失败 > 90 天零触发 > 语义近邻合并 > 上游化）走人工裁决。⛔ 绝不为腾位静默删除。

### 6.3 一致性扫描

每第 3 轮归纳（learn_count % 3 == 0）对现存 active 规则做全两两一致性扫描（≤30 条量级可控）；worker 执行中遇到规则互斥 → 落 `type: correction, sub: other, note: rule-conflict L-a/L-b` 事件，sm-learn 见到强制出修订案。执行期冲突裁决：**适用条件越窄越优先**，输出注明一行。

---

## §7 安全轨（不可覆盖域）

学习规则**永远不能**触碰：preamble 6 步 / postamble 8 步 / 证据分级（完整中文五档）/ "仍需补的资料"非空 / 合规声明 / Dual Output / 数据源纪律（adapters + compliance）/ L2"不能删父 skill 必需段"。

- ⛔ sm-learn 对 harness 主库（`skills/` `core/`）**零写入**——一切写回只进 workspace
- ⛔ `.learning/` 与 `overlays/` 默认 git-ignore，绝不进任何 repo
- ⛔ 规则必须是可观测行为句，禁止画像句
- 监督边界：监工 agent 自发干预**永不入池**（回音室）；needs_user 后用户亲自裁决的内容由 worker 落账（`src: supervisor`），与主会话纠正同权重。监工会话对 `.learning/` 零写权

### 单写者表

| 文件 | 写者 | 备注 |
|---|---|---|
| question-ledger.jsonl / trial-log.md | postamble（append-only） | sm-learn 只读 + 归档搬移 |
| learn-state.json | postamble 递增计数字段 · sm-learn 其余字段 | ts 乐观锁 |
| learned-rules.md / overlays / questions.md / adopted-rules.md / rejected.md | sm-learn | 自动通道或裁决后 |

---

## §8 判例锚（采集判定的 few-shot，防口径漂移）

| 用户说 | 判定 | 理由 |
|---|---|---|
| "客户集中度呢，这个没写" | 采：correction/method，home=当前 skill | 对产出结构的纠正 |
| "H20 恢复对 FY27 收入影响多大" | 采：follow-up，home=deepdive 或 earnings-preview | 分析类追问 |
| "这个折旧假设是不是太乐观"（在 deepdive 会话中） | 采：question，**home=model-check** | 问题回家：内容属模型审阅 |
| "今天为什么跌"（在 deepdive 会话中） | 采：question，**home=close-recap** | 同上 |
| "NVDA 今天收盘多少" | 不采 | 纯数据查询 |
| "先别管估值，看竞争格局" | 采：redirect，section=估值 | C3 证据（默认条件化） |
| "这个表不错" | 采：approval/weak | 阻断同段降权用 |
| "以后测算都给三档" | 采：approval/strong 或 correction/method | 显式泛化 |
| "继续 t-014" / "深度看英伟达" | 不采 | 机制操作 / 路由触发 |
| "我准备加仓了" | 不采 ⛔ | 仓位表述，合规+隐私 |
| "还是老问题"（指上次的市场空间拆分） | 采，raw 写解引用后实义："市场空间又只给总量未拆分" | 指代必须解引用 |
| "把这些问题学进去：…"（贴老师清单） | 逐条采：src=mentor | 高权威通道 |
| "数据别用券商的，去翻 10-K"（外发点评会话） | 采：correction/src，**scene=外发** | scene 锁定，不污染讨论层 |
| "辛苦了" | 不采 | 寒暄 |

漂移自检：sm-health-check 抽 10 条历史事件按当前口径重判，一致率 <80% → 提示口径已漂移。

---

## §9 mentor-import（唯一的用户主动通道）

触发："把这些问题学进去：…"。免频次/标的/日期阈值（用户明示背书即证据），**不免**：泛化改写、三重冲突检查、**对目标 skill 主库必答问题 + 现有 overlay 的重复检查**（双向满足测试，已覆盖的标"已覆盖"不入库）。原文全文存 `mentor-imports/YYYY-MM-DD.md`；条件前缀（"对代工模式的公司要问…"）必须保留进规则文本。单次入库 ≤8 条（超出 carryover），受单 skill 并发 trial ≤5 限制。逐条确认（可"全部采纳"，应答须复述条数）。

---

## §10 token 总账（诚实口径）

| 项 | 成本 | 频率 |
|---|---|---|
| 采集（典型/满载） | ≤200 / ≤600 tokens | 每会话 |
| preamble Step 0.7 加载 | ≤2000 字符（全局+overlay 合计上限） | 每 skill 调用 |
| 自动归纳一轮 | 3-8k tokens | 每 4 会话 |
| 摊薄 | 约 +1.5-2.5k tokens/会话 | 对照 Dual Output ~5.5k/任务，学习总开销 <40% 单任务成本，换"越用越懂你" |
