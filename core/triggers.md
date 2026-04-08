# Auto-Triggers · LLM 自动识别表

> 本文件解决 investor-harness 的根本问题：**LLM 默认走捷径，不会主动调 skill**。
>
> 用户 / CLAUDE.md / agent.md 只能"软提醒"，无法硬拦截。唯一的防御是：LLM 在看到用户消息的那一刻，用本文件的关键词表做 **pattern matching**，命中即触发对应 skill。
>
> v0.4 新增。配合 CLAUDE.md 的 eager-loaded 硬约束一起使用。

---

## 使用方法

LLM 在每次收到用户消息后，**第一件事**是扫描消息文本，匹配下表中的触发词：

1. 如果命中任一触发词 **且** 消息里提到覆盖池中的 ticker / 公司名
2. **立即停止"自由回答"模式**，改为"skill 调用"模式
3. 在回答开头明确声明："识别到触发词 `{word}`，按 investor-harness 纪律执行 `sm-{skill}`"
4. 按 preamble.md 走 Step 0-5
5. 调对应 skill
6. 按 postamble.md 收尾

---

## 触发词表

### 估值类 → `sm-company-deepdive` + `sm-thesis`

| 中文触发词 | 英文触发词 |
|---|---|
| 估值怎么样 / 估值如何 | valuation / how is the valuation |
| 贵不贵 / 便宜不便宜 | expensive / cheap / overvalued / undervalued |
| P/E / PE 多少 | multiple / trading multiple |
| 值多少钱 / fair value | fair value / intrinsic value |
| 目标价 | target price / price target / TP |
| 合理估值 | justified multiple |

### 评级 / 买卖类 → `sm-thesis` + 必配 `sm-red-team`

| 中文 | 英文 |
|---|---|
| 值不值得买 | worth buying / should I buy |
| 看多看空 | bullish / bearish |
| 买入 / 卖出 / 持有建议 | buy / sell / hold recommendation |
| Rating / 评级 | rating / upgrade / downgrade |
| 多头逻辑 / 空头逻辑 | bull case / bear case |

### 业务 / 商业模式类 → `sm-company-deepdive`

| 中文 | 英文 |
|---|---|
| 做什么的 / 主营业务 | what does X do |
| 商业模式 | business model |
| 产业链位置 | value chain position |
| 收入来源 | revenue breakdown / segment |
| 客户结构 | customer concentration |
| 核心竞争力 | moat / competitive advantage |

### 财报类 → `sm-earnings-preview`

| 中文 | 英文 |
|---|---|
| 财报 / 业绩 | earnings / Q1 / Q2 / Q3 / Q4 results |
| 下季度 / 下次业绩 | next quarter |
| Beat / Miss | beat or miss |
| 预期 / 指引 | guidance / consensus |

### 比较类 → 两次 `sm-company-deepdive` + 合并

| 中文 | 英文 |
|---|---|
| A 和 B 对比 / 比较 | X vs Y / compare X and Y |
| 谁更好 | which is better |
| 相对估值 | relative valuation |

### 模型 / DCF 类 → `sm-model-check`

| 中文 | 英文 |
|---|---|
| 财务模型 | financial model |
| DCF 合理吗 | DCF reasonable |
| 假设怎么看 | assumptions check |
| WACC / 永续增长 | WACC / terminal growth |

### 催化剂 / 触发事件类 → `sm-catalyst-monitor`

| 中文 | 英文 |
|---|---|
| 催化剂 | catalyst |
| 下 3 个月关注什么 | next 3 months |
| 驱动因素 | driver |

### 一致预期类 → `sm-consensus-watch`

| 中文 | 英文 |
|---|---|
| 卖方最近怎么看 | sell-side view |
| 一致预期 | consensus estimate |
| 预期差 | expectation gap |
| 分析师评级变化 | analyst rating changes |

### 反方 / 红队类 → `sm-red-team`

| 中文 | 英文 |
|---|---|
| 反方 / 红队 | red team / devil's advocate |
| 多头逻辑有什么问题 | what could go wrong |
| 最大风险 | biggest risk |

### 路演 / 调研问题 → `sm-roadshow-questions`

| 中文 | 英文 |
|---|---|
| 见管理层问什么 | mgmt meeting questions |
| 路演问题 | roadshow questions |
| 调研清单 | diligence questions |

### PM 一页纸 → `sm-pm-brief`

| 中文 | 英文 |
|---|---|
| PM 视角 | PM view |
| 一页纸 | one-pager / brief |
| 投资要点 | investment summary |

### 简报类 → `sm-briefing`

| 中文 | 英文 |
|---|---|
| 今日动态 / 今天怎么样 | today's news |
| 本周要点 | weekly brief |
| 日报 / 周报 | daily briefing |

### 行业地图类 → `sm-industry-map`

| 中文 | 英文 |
|---|---|
| 产业链 / 行业全景 | industry map |
| 赛道玩家 | players in the space |
| 上下游 | value chain upstream/downstream |

---

## 防御规则

### 规则 1：宁可多触发，不可漏触发

触发了没必要的 skill → 代价是几秒钟额外 context read
漏触发 → 代价是违反纪律 + 用户被动发现 + 信任崩塌

**优先级：触发 > 效率**。

### 规则 2：模糊命中也要触发

用户说"NVDA 咋样"—— "咋样"不是精确触发词，但意图明显。**命中语义而非字面**。

### 规则 3：同一消息多词命中，取优先级最高

优先级：`sm-red-team > sm-thesis > sm-company-deepdive > 其他`

如果用户说"NVDA 值不值得买？要考虑反方"—— 同时触发 thesis + red-team，两个都要跑。

### 规则 4：用户明确说"快速看一下"时

仍然 MUST 执行最小集合：
1. `[Preflight]` 段（可以简化）
2. 关键事实带证据等级
3. 末尾合规声明

允许省略的：完整 9 段式 deepdive、历史输出检查、归档步骤

### 规则 5：**违规自我报告机制**

如果 LLM 发现自己**已经开始输出** 但意识到漏触发了，MUST 立即：
1. 停止当前输出
2. 说："违规检测：我漏触发了 sm-{skill}，现在回滚并按纪律重做"
3. 重启流程

---

## 反例集合（LLM 易犯错误）

### 反例 1：估值表格式输出

❌ **违规**：用户问"KEYS 和 MU 估值怎么样"，LLM 直接拉 yfinance 数据出一张 fwd P/E 表格 + 多空观点。

✅ **正确**：识别"估值怎么样"+ "KEYS / MU 是覆盖池成员"→ 触发 `sm-company-deepdive`（两次）→ 完整 9 段式 → postamble 归档。

### 反例 2：闲聊式开场

❌ **违规**：用户说"最近 NVDA 跌了，怎么看"，LLM 聊天式开始："NVDA 最近回调主要因为..."

✅ **正确**：识别"怎么看"+ "NVDA"→ 触发 `sm-thesis`（命题构建）+ `sm-red-team`（反方）→ 按结构输出。

### 反例 3：只加合规声明不调 skill

❌ **违规**：LLM 写了一段自由分析，末尾加"以上仅供参考，不构成建议"—— 认为这样就合规。

✅ **正确**：合规声明**只是**交付的一部分，不是 skill 的替代。必须先调 skill 走流程，然后 postamble 才加合规声明。

### 反例 4：跳 Preflight

❌ **违规**：调了 skill 但直接开始 9 段式输出，没写 `[Preflight]`。

✅ **正确**：调 skill → 先写 `[Preflight]`（标的/市场/数据源链/缺失项）→ 再 9 段式。

---

## 落地建议

本文件需要配合以下两个机制之一才能发挥作用：

1. **CLAUDE.md eager-load**（分析师工作区的 CLAUDE.md 引用本文件，让 LLM 每次启动时都看到）
2. **Hooks 拦截**（UserPromptSubmit 时运行脚本，扫描触发词，命中时注入 system-reminder）

单独的 triggers.md 没有效果，必须有外部机制让 LLM 读到它。

---

## 版本

- v0.4.1（本版）：首次引入 auto-trigger 概念，配合 CLAUDE.md 硬约束
- 未来 v0.5 计划：实现 hooks 脚本，从机制上拦截用户 prompt
