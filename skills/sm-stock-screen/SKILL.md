---
name: sm-stock-screen
description: 选股 / 找标的 skill。用于把一个模糊的方向、产业链缺口、景气环节或"涨得少"的想法，拆成可执行的筛选框架、候选池和后续研究顺序。也支持 ClawHub / 外部 strategy registry、多策略对比、共识票/分歧票归因和观察池扩充。
inputs:
  - 主题 / 问题（如"AI 链条里还缺什么"、"MLCC 里筛标的"、"跟 AI 相关但涨得少的板块"）
  - 可选：市场范围（A/H/US）
  - 可选：筛选风格（基本面优先 / 低涨幅补涨 / 预期差 / 高弹性）
  - 可选：策略模式（单一路径筛选 / 多策略共识比较）
outputs:
  - 选股框架
  - 候选标的分层清单
  - 多策略共识矩阵（如果用户要求）
  - 下一步研究顺序
  - 可复用的思路模板
data_sources:
  - 见 ../../core/adapters.md
  - iFind search_stocks
  - 行业 / 公司公开资料
  - references/clawhub-quant-registry.md（仅当用户要求外部 strategy 对比）
markets: [CN-A, HK, US, GLOBAL]
trigger: 用户明示"选股 / 筛标的 / 挖标的 / 哪些票值得看 / AI 链里还缺什么 / 涨得少的 AI 板块 / 共识票 / 多策略 / strategy compare / ClawHub 选股"
---

# SM Stock Screen

这个 skill 负责把"我大概想看一个方向"变成"我先研究哪 5-10 个票"。  
当用户明确要求多策略、共识票、ClawHub skill、10 个 strategy 对比时，它还负责把外部选股 skill 收编成统一的比较框架。

## 强制流程（v0.2 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 6 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 8 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检

Stock Screen 特别注意：

- **先定义问题，再筛股票**；不要直接报一串名字
- **必须把筛选逻辑写清楚**：是景气度、供给瓶颈、估值切换、低涨幅补涨，还是预期差
- **输出不是结论，而是研究优先级**
- **多策略模式下，先定义可比口径，再比较结果**

## 先判定是哪个模式

### 模式 A：标准选股

适用于：

- "AI 链条上还缺什么"
- "MLCC 里帮我挖几个重点标的"
- "跟 AI 相关但涨得比较少的板块还有谁"
- "给我一个选股思路模板，不要直接报票"

### 模式 B：多策略共识比较

适用于：

- "把这些选股 skill 都拉进来比较"
- "我有 10 个 strategy，看看共同推荐了什么"
- "ClawHub 上和量化选股相关的 skill 跑一个 registry"
- "哪些票是多策略共识，哪些只是单一风格选出来的"

### 读取规则

- 进入 **模式 B** 时，先读 [`references/strategy-compare-contract.md`](references/strategy-compare-contract.md)
- 进入 **模式 B** 时，**必须**读 [`references/clawhub-quant-registry.md`](references/clawhub-quant-registry.md)，并把它当作本模式的**默认 canonical roster**
- 用户要求 **刷新、增删、补录外部策略** 时，再读 [`references/strategy-refresh-playbook.md`](references/strategy-refresh-playbook.md)
- **不要**因为当前工作区恰好装了某些本地 skill，就自动改用本地 roster；除非用户明确说"改用本地已安装 skill"或"把本地 skill 也并入比较"

## 五种默认筛法（模式 A）

### 1. 瓶颈环节筛法

适合："AI 链条里还缺什么？"

- 找出主线已经验证的环节
- 找 supply chain 里被忽视但必要的器件 / 材料 / 设备
- 关注"量先上去、利润后反映"的环节

### 2. 低涨幅补涨筛法

适合："跟 AI 相关，但涨得比较少的板块有哪些？"

- 先确认主线已经涨了什么
- 再找同样受益、但涨幅落后 / 仓位不重 / 预期不满的公司
- 排除纯左侧价值陷阱

### 3. 预期差筛法

适合："市场还没 fully price in 的票有哪些？"

- 行业逻辑已经形成共识
- 公司层变量还没被充分上修
- 看未来 1-2 个季度有没有验证点

### 4. 产业链扩散筛法

适合："主线从龙头往哪里扩？"

- 先定龙头和直接受益
- 再看二阶 / 三阶受益
- 判断扩散是走业绩、走弹性，还是走情绪

### 5. 错杀修复筛法

适合："基本面相关，但因为别的原因涨得少 / 跌得多"

- 先确认是否真相关
- 再找错杀原因：财报短期 miss、仓位、流动性、非核心业务拖累
- 看修复催化是否明确

## 多策略共识模式（模式 B）

模式 B 的核心不是"把一堆 skill 名单堆在一起"，而是做三个动作：

1. **建 roster**：先明确这次要纳入哪些 strategy，哪些只是数据层 / validator / router
2. **统一口径**：把不同 strategy 的输出映射成统一 schema，再做 raw/family-adjusted 共识
3. **解释差异**：说明共识票为什么重合，分歧票为什么只被某类风格选中

### 模式 B 的硬规则

- **默认 roster 只认** `references/clawhub-quant-registry.md` 里登记过的 strategy；没有登记的 strategy，哪怕当前工作区可用，**也不能自动纳入**
- **本地已安装 skill 不等于 mode B roster**；本地 skill 只有两种情况下才能进入：
  1. 它在 registry 里有对应 `owner/slug` / strategy card
  2. 用户明确要求切到 `local roster mode`
- **外部 skill 默认视为 strategy card，不等于真的安装进当前工作区**
- **只有 `generator` 才能直接投票产出候选池**
- **`validator` 只能做通过/否决/降级，不单独制造 universe**
- **`data` / `meta` / `router` 技能默认不算票**
- **同一家族的近似策略不能重复计票**
  - 例如 `tvscreener` 和 `tradingview-screener` 属于同一 TradingView 族，raw 可以双记，family-adjusted 只能算 1 票

### 模式 B 的输出目标

- `共识票`：被多个独立策略家族同时命中的标的
- `分歧票`：只被单一路径命中，或被 validator 否决的标的
- `原理归因`：每只票到底是被趋势、资金、估值、宏观、情绪、主题扩散中的哪条逻辑选出来的
- `下一步研究顺序`：哪几只值得调 `sm-thesis` / `sm-company-deepdive`

## 输出格式

### 模式 A：标准选股输出

```markdown
# Stock Screen · {主题}

## 一句话筛选命题
- {例如“AI 训练链已经交易到光模块，但 MLCC / 高频被动件的二阶受益尚未充分定价”}

## 先筛什么，不筛什么
- 纳入：{市场 / 子行业 / 市值段 / 业务暴露}
- 排除：{纯概念、业务相关度弱、数据无法验证}

## 候选池

| 分层 | 股票 | 为什么入池 | 现在最大的疑问 | 建议下一步 |
|---|---|---|---|---|
| A 级优先看 | ... | ... | ... | 调 `sm-thesis` |
| B 级观察 | ... | ... | ... | 等数据 / 等催化 |
| C 级备选 | ... | ... | ... | 暂不深挖 |

## 这次用的筛法
- 瓶颈环节 / 低涨幅补涨 / 预期差 / 产业链扩散 / 错杀修复

## 可复用模板
1. 先问：主线已经涨了谁？
2. 再问：谁是真受益但还没涨够？
3. 再问：缺的验证数据是什么？
4. 最后分成 A/B/C 三层，不要一次全做深度
```

### 模式 B：多策略共识输出

```markdown
# Strategy Compare · {主题 / 市场 / 时间窗}

## 这次比较的问题是什么
- {筛选命题}

## 本次纳入的 strategy roster
| strategy | family | role | vote_mode | 市场 | 出处 |
|---|---|---|---|---|---|

## 为什么这些 strategy 可比 / 不可比
- generators: 负责产出候选池
- validators: 负责对候选池做通过/否决
- data/meta: 不计票，只补数或编排

## 候选池并集（union pool）
| 股票 | 首次命中 strategy | 主逻辑标签 | 备注 |
|---|---|---|---|

## 共识矩阵
| 股票 | raw_hits | family_hits | validator_pass | validator_reject | 主逻辑 | 结论 |
|---|---:|---:|---:|---:|---|---|

## A级共识票
| 股票 | 为什么被多策略同时选中 | 主要分歧点 | 建议下一步 |
|---|---|---|---|

## B级交叉风格票
| 股票 | 命中哪些风格 | 为什么暂不升 A | 建议下一步 |
|---|---|---|---|

## C级单一策略票 / 分歧票
| 股票 | 只被谁选中 | 可能的偏见或限制 | 是否保留观察 |
|---|---|---|---|

## 这些重合是怎么来的
- 趋势共识 / 估值共识 / 主题扩散 / 资金流向 / 情绪催化 / 宏观门控

## 下一步研究顺序
1. {A级里最值得调 `sm-thesis` 的票}
2. {需要 `sm-consensus-watch` 补预期差的票}
3. {需要 `sm-company-deepdive` 深挖的票}
```

## 典型触发例子

- "AI 链条上现在哪些东西比较缺？"
- "MLCC 和 TWS 里帮我挖几个重点标的"
- "跟 AI 相关但涨得比较少的板块还有谁"
- "把 ClawHub 上选股的 skill 收进来做一个比较"
- "我这里有 10 个 strategy，看看共同推荐的是什么"
- "给我一个共识票框架，不要只报票"

## 约束

- ❌ 不直接给"必涨股"名单
- ❌ 不把弱相关公司硬扯进 AI 链
- ❌ 不把选股候选池写成深度报告
- ❌ 不把 `data` / `meta` / `router` 技能当成投票器
- ❌ 不让同一家族的重复策略无限加权
- ❌ 用户未明示时，用当前环境里"恰好可用"的本地 skill 替代 registry 里的 Claude Hub strategy
- ✅ 必须分层（A/B/C）
- ✅ 必须说明这次筛法或策略 roster
- ✅ 必须明确下一步是调哪个 skill 去深挖
- ✅ 用户要求外部 strategy 时，必须显式写出处（至少 `owner/slug` 或源码链接）

## 输出归档路径

```text
themes/{theme-slug}/stock-screen/{YYYY-MM-DD}-{screen-slug}.md
```

## 与其他 skill 的关系

| 关系 | 说明 |
|---|---|
| **上游** | 可先调 `sm-industry-map` 搭产业链框架 |
| **并行** | 模式 B 可引用 `references/clawhub-quant-registry.md` 做 strategy roster |
| **下游** | A 级候选进入 `sm-thesis` / `sm-company-deepdive` |
| **互补** | `sm-consensus-watch` 负责预期差验证，`sm-stock-screen` 负责先找池子 |
| **审计** | registry 刷新和增补按 `references/strategy-refresh-playbook.md` 执行 |

## 实操提醒

- 用户说"把这些 skill 装进来"时，默认理解为**装进选股方法板块 / registry**，不是立刻安装所有外部 skill
- 只有用户明确要求安装某个外部 skill 时，才进入真实安装流程
- 默认先做 registry、对比、共识和研究顺序；把"方法编排"和"真实执行"分开
- 如果用户没有特别说明，模式 B 的 strategy roster 以 `clawhub-quant-registry.md` 为准，不做本地自动发现
