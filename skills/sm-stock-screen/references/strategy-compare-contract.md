# Strategy Compare Contract

> 当 `sm-stock-screen` 进入多策略模式时，按本合同统一口径。  
> 目标不是把每个 skill 都"跑一遍"，而是把**不同角色的 strategy**装进同一个比较语言。

## 1. 先分角色

### A. `generator`

- 从一个 universe / theme / watchlist 里产出候选池
- 可以直接贡献 `hit`

### B. `validator`

- 不从空白 universe 直接报池子
- 只能对 generator 产出的候选池给 `pass / reject / downgrade`

### C. `data`

- 只补行情、逐笔、新闻、财务
- 默认不计票

### D. `meta`

- 只做路由、预算和编排
- 默认不计票

## 2. 统一 schema

每个 strategy 的输出都要映射成下面的最小 schema：

| 字段 | 说明 |
|---|---|
| `strategy_id` | 外部 strategy 标识 |
| `family` | 策略家族 |
| `role` | generator / validator / data / meta |
| `vote_mode` | direct / gate / none |
| `market` | CN-A / HK / US / GLOBAL |
| `symbol` | 标准代码 |
| `display_name` | 股票简称 |
| `recommendation` | `SELECT` / `WATCH` / `REJECT` / `PASS` / `AVOID` |
| `score_raw` | 原始分数或 rank |
| `score_norm` | 如可换算，则标准化到 0-100；不可换算就留空 |
| `timeframe` | intraday / short / swing / medium / long |
| `style_tags` | `momentum` / `flow` / `valuation` / `macro` / `sentiment` / `theme` / `quality` / `technical` |
| `reason_short` | 1 句话说明为什么命中 |
| `source_ref` | `owner/slug` 或源码链接 |

## 3. 先做并集，再做 gate

### Step 1

先跑所有 `generator`，拿到 `union pool`

### Step 2

对 `union pool` 去重，优先统一成：

- A 股：`000001.SZ` / `600519.SH`
- 港股：`0700.HK`
- 美股：`AAPL.US`

### Step 3

如果候选池太大，先按以下优先级缩到 `Top N` 再交给 `validator`：

1. family 命中数高
2. score_norm 高
3. 用户指定风格更匹配
4. 数据最完整

### Step 4

再让 `validator` 给每只票打 `pass / reject / downgrade`

## 4. 共识指标

### 原始指标

| 指标 | 含义 |
|---|---|
| `raw_hits` | 命中该股票的 generator 数量 |
| `family_hits` | 命中该股票的独立 family 数量 |
| `validator_pass` | validator 通过数 |
| `validator_reject` | validator 否决数 |
| `style_diversity` | 命中的不同 style_tags 数量 |

### 结论标签

#### `A-Core`

满足：

- `family_hits >= 3`
- `validator_reject = 0`
- `style_diversity >= 2`

含义：

- 这是跨 family 的核心共识票

#### `B-Cross-Style`

满足：

- `family_hits = 2`
- 或 `family_hits >= 1` 且 `validator_pass >= 2`

含义：

- 有一定共识，但还不是硬共识

#### `C-One-Engine`

满足：

- `family_hits = 1`
- 或 `validator_reject >= 1`

含义：

- 单一路径命中，或者分歧较大，先列观察而不是升格

#### `Red-Flag`

满足：

- `family_hits >= 2`
- 且 `validator_reject >= 2`

含义：

- 表面热门，但被多个审单器否掉；必须解释冲突

## 5. 家族去重

同一 family 的多个 strategy 不能让共识虚高。

### 例子

- `tvscreener` + `tradingview-screener`
  - `raw_hits = 2`
  - `family_hits = 1`

- `mx-stocks-screener` + `em-stockpick`
  - 如果本质上是同一套东方财富自然语言筛选，默认 `family_hits = 1`

## 6. 推荐输出

最终比较至少要有这 8 段：

1. `本次比较的问题`
2. `本次纳入的 strategy roster`
3. `为什么这些 strategy 可比 / 不可比`
4. `候选池并集`
5. `共识矩阵`
6. `A/B/C 分层结论`
7. `这些重合和分歧是怎么来的`
8. `下一步研究顺序`

## 7. 不允许的错误比较

- ❌ 把 `validator` 当成 generator 直接报全市场 Top10
- ❌ 把 `data` 技能当成策略票
- ❌ 把同一家族重复记成多个独立共识来源
- ❌ 不区分时间窗，把 3 天短线和 6 个月长线放一张票表里硬比
- ❌ 只报"共同推荐了谁"，却不解释为什么会重合

## 8. 结尾必须回答的 4 个问题

1. 哪些票是**跨 family** 的真共识？
2. 哪些票只是某一类风格偏见下的单一命中？
3. 哪些票被 generator 看好，但被 validator 否掉？
4. 哪些票最值得送进 `sm-thesis` / `sm-company-deepdive`？
