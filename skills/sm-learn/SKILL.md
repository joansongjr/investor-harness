---
name: sm-learn
description: 提问驱动自主学习的归纳 skill（v0.9.7）。自动触发为主：每 3-5 次 skill 会话，postamble 自动跑一轮归纳——读 .learning/question-ledger.jsonl 增量，按"问题回家"原则聚类（问模型的问法反补 sm-model-check、问复盘的反补 sm-close-recap），过阈值（≥3 次 · ≥2 标的 · ≥2 天）与三重冲突检查后自动生效进试用期（每轮 ≤3 条），会话尾一行摘要告知，用户保留"撤销 L-xxx"否决权。手动触发用于：mentor 导入（"把这些问题学进去"）、审计（"看看学了什么"）、撤销/恢复、强制归纳（"归纳提问"）。绝不修改 harness 主库，绝不覆盖证据分级 / 合规 / 数据源硬约束。
---

# SM Learn（提问驱动自主学习 · 归纳与写回）

> **它自主运行**——用户不需要说任何话，机制就在采集、归纳、生效、验证。用户只保留否决权。
> 数据契约、阈值、自动化边界的唯一规范源是 [`../../core/learning.md`](../../core/learning.md)（与本文件冲突时以它为准）。本文件是归纳侧操作手册。

## 接口

- 输入：`.learning/question-ledger.jsonl` 自 cursor 之后的增量；可选：用户 mentor 导入清单
- 输出：自动生效的试用规则（overlay / learned-rules / questions.md）+ 会话尾摘要；人工通道的提案（修订案 / C4 新 skill / 本地规范冲突项）
- 数据：只读 workspace `.learning/`、`user-skills/overlays/`、coverage 归档，**不取外部数据**
- 市场：与标的无关的元 skill

## 触发方式

| 方式 | 场景 |
|---|---|
| **自动（主通道）** | postamble Step 5.5 检测 `sessions ≥ 4` 或 `events ≥ 15` → 会话收尾内联跑一轮；`sessions = 5` 强制 |
| 手动归纳 | "归纳提问" / "跑 sm-learn" |
| mentor 导入 | "把这些问题学进去：…"（唯一必须用户主动的通道，见 learning.md §9） |
| 台账操作 | "看看学了什么" / "撤销 L-xxx" / "恢复 L-xxx" / "看提案" / "重建 learned-rules" |

## 必答问题（每轮归纳输出前自问）

- 这轮处理了哪个区间（cursor 从哪个事件 id 到哪个，共几条 · 几会话 · 几标的）
- 每条自动生效规则背后是几次 · 几标的 · 几日期，raw 原话锚样本是哪几条
- 聚类用的意图短语是否全部来自受控词表（新增短语过了双向满足测试吗）
- 每条规则文本是可观测行为吗，适用条件从句（scene / 板块 / 触发条件）带了吗
- seen-diff 略过了哪些簇，依据哪条台账
- 有没有候选进了人工通道（修订案 / C4 / 本地规范冲突），为什么
- 上限余量（全局 30 条 / overlay 1000 字符 / 单 skill trial 5 条）还剩多少

## 工作循环（自动轮）

1. **读增量**：learn-state cursor（事件 id）之后的行；坏行跳过计数不删除；>50 条截断 carryover
2. **清洗分池**：问法池（question/follow-up）/ 纠正池（correction/redirect）/ 佐证池（approval）/ C4 池（home=none）；norm 缺失的离线二次归一
3. **两遍聚类**：within-home → cross-home 合并（learning.md §3.2）；意图短语走受控词表
4. **seen-diff**：候选簇 vs 台账全量逐对语义比对（锚样本），命中 active 转 recurrence 观测，命中管护性退役主动提示恢复
5. **阈值 + 泛化**：≥3 次 · ≥2 标的 · ≥2 天；标的替换测试三档（全局 / 板块条件 / 单标的）；10 日窗标"疑似事件驱动"转条件规则
6. **三重冲突检查**：硬约束 → blocked；规则矛盾 → 修订案（人工）；本地规范 → 提醒项（人工）
7. **自动生效**：按证据强度前 3 条直写试用期（`auto: true`），其余入观察池
8. **顺带结算**：到期 trial 规则按 learning.md §5.2 判转正 / 自动停用 / 延长 / 低频转正；spot-check 一句话非阻塞
9. **收尾**：推进 cursor · 清零计数 · 更新 vocab/watch/carryover · 每第 3 轮跑规则两两一致性扫描 · 输出摘要块

## 输出格式（会话尾摘要，自动轮）

```
🧠 自主学习（第 {n} 轮）：处理 {N} 条事件（{s} 会话 · {t} 标的）→ 聚 {k} 簇
   自动生效 {m} 条（试用中）：
   L-{id} [{home}] {类型}：{规则一句话}（证据 {x} 次·{y} 标的）
   …
   {停用 {p} 条（试用失败，"恢复 L-xxx"可复活）}
   {待人工裁决 {j} 条，说"看提案"展开}
   {观察池 {w} 簇（top1：{指纹} 差 {缺口}），说"看观察池"展开}
   撤销任一条："撤销 L-xxx" · 审计："看看学了什么"
```

手动归纳 / mentor 导入 / 提案展开时走完整报告（Dual Output：对话贴全 + 归档 `.learning/proposals/YYYY-MM-DD-learn.md`），提案条目含：类型 / 证据强度 / 原话证据（日期+标的+事件 id）/ 建议写入位置 / 规则文本 / 冲突检查结论 / 四选项裁决。

## 约束

- ❌ 不碰 harness 主库（`skills/` `core/` 零写入）——一切写回只进 workspace
- ❌ 不学硬约束的对立面（learning.md §7 清单；冲突项 blocked）
- ❌ 不写画像句——每条规则可观测、带必要的适用条件从句
- ❌ 自动通道不处理：修订案 / C4 新 skill / 本地规范冲突 / 无条件降权——这四类必须人工裁决
- ❌ 不为腾位静默删除任何规则；不重提用户明拒的提案（2 倍门槛 + 显式披露历史）
- ❌ 单轮自动生效 ≤3 条 · 单 skill 并发 trial ≤5 条 · 全局 ≤30 条 / 2000 字符
- ✅ 一切自动写入可逆（"撤销 / 恢复 L-xxx"）、可审计（"看看学了什么"）、留痕（台账 + 事件 id 出处）

## 与其他 skill 的关系

| 关系 | 说明 |
|---|---|
| 上游 | 全部 sm-* skill 的 postamble Step 5.5 采集事件（sm-learn 只消费） |
| 下游 | preamble Step 0.7 加载 overlay + learned-rules，使规则生效 |
| 边界 | sm-supervisor：监工自发干预永不入池；needs_user 用户裁决由 worker 落账（src: supervisor）；监工对 .learning/ 零写权 |
| 互补 | sm-health-check：规则健康度统计 + 采集口径漂移抽检（learning.md §8） |

## 参考

- [../../core/learning.md](../../core/learning.md) — 唯一规范源（必读全文）
- [../../core/user-skills.md](../../core/user-skills.md) — overlay 载体与 L3 规范
- [../../core/preamble.md](../../core/preamble.md) — Step 0.7 加载学习产物
- [../../core/postamble.md](../../core/postamble.md) — Step 5.5 采集与自动触发
- [../../core/acceptance.md](../../core/acceptance.md) — sm-learn 专属验收清单
