# ClawHub Quant Registry

> 用于 `sm-stock-screen` 的外部 strategy 花名册。  
> 本文件不是"推荐榜"，而是可比策略的**出处登记 + 家族映射 + 投票角色说明**。
>
> **Mode B 默认规则**：如果用户没有明确要求改用本地已安装 skill，本文件就是 `sm-stock-screen` 模式 B 的 **canonical roster**。不要自动用当前环境里可用的本地 skill 替换这里的 strategy。
>
> Snapshot：`2026-05-29`

## 字段说明

| 字段 | 含义 |
|---|---|
| `role` | `generator` 产池，`validator` 审核候选，`data` 补数，`meta` 编排 |
| `vote_mode` | `direct` 直接投票，`gate` 只做通过/否决，`none` 不计票 |
| `family` | 同一数据或逻辑家族；family-adjusted 共识最多算 1 票 |
| `comparable` | `yes` 可直接进入共识矩阵，`conditional` 需要先限定 universe，`no` 默认不进共识 |

## 先看全表

| strategy_id | role | vote_mode | family | comparable | 市场 | 核心原理 | 出处 |
|---|---|---|---|---|---|---|---|
| `a-stock-picker` | generator | direct | three-layer-a-share | yes | CN-A | 5维量化初筛 -> 5项定性验证 -> 择时 | `danpian1/a-stock-picker` |
| `mx-stocks-screener` | generator | direct | eastmoney-natural-language | yes | CN-A/HK/US | 东方财富妙想自然语言筛选 | `financial-ai-analyst/mx-stocks-screener` |
| `iwencai-screener` | generator | direct | wencai-theme | yes | CN-A | 先拆核心利好方向，再去 i问财抓前5 | `caobingxi/iwencai-screener` |
| `stock-select` | generator | direct | stockboot-level2 | yes | CN-A | 自然语言选股 + Level2 主力资金 + 交易接口 | `wanghl-cn/stock-select` |
| `yufeng-stock-screener` | generator | direct | cloud-shortterm-score | yes | CN-A | 技术/资金/筹码/板块轮动四维评分 + 8日择时 | `wsy0303/yufeng-stock-screener` |
| `zjtj-sar-quantum-strategy` | generator | direct | rule-based-shortterm | yes | CN-A | ZJTJ + SAR + 成交量 + 情绪四维短线规则 | `haohanyang92/zjtj-sar-quantum-strategy` |
| `intellectia-stock-screener` | generator | direct | pattern-preset | yes | US/Crypto | Bullish/Bearish preset + probability/profit 排序 | `xanxustan/ai-screener` |
| `tvscreener` | generator | direct | tradingview-query | yes | CN-A/HK/US | TradingView 字段/过滤器直接查询 | `subway-chenyan/tvscreener` |
| `tradingview-screener` | generator | direct | tradingview-query | yes | GLOBAL | TradingView API + YAML 信号引擎 | `hiehoo/tradingview-screener` |
| `banana-farmer` | generator | direct | momentum-social | yes | US/Crypto | Ripeness score：技术 + 动量 + 社交热度 | `adamandjarvis/banana-farmer` |
| `stock-analysis` | generator | direct | yahoo-hot-rumor | conditional | US/Crypto | Yahoo 数据 + hot scanner + rumor scanner | `udiedrichsen/stock-analysis` |
| `stock-copilot-pro` | validator | gate | multi-source-global-evaluator | conditional | CN-A/HK/US | QVeris 多源 quote/fundamental/news/social 汇总 | `buxibuxi/stock-copilot-pro` |
| `yumstock` | validator | gate | macro-gated-single-name | conditional | US | 宏观门控 + 技术35 + 基本面25 + 宏观40 | `yumyumtum/yumstock` |
| `stock-evaluator-v3` | validator | gate | valuation-dashboard | conditional | US | 单票深评 + 仪表盘 + 估值/质量/技术 | `demandgap/stock-evaluator` |
| `em-stockpick` | generator | direct | eastmoney-natural-language | yes | CN-A/HK | 东方财富官网自然语言条件选股 | `silverfoxchina-gif/em-stockpick` |
| `a-share-real-time-data` | data | none | china-market-data | no | CN-A | mootdx/TDX 实时行情与逐笔 | `wangdinglu/a-share-real-time-data` |
| `stock-picker-orchestrator` | meta | none | orchestrator | no | GLOBAL | 任务路由与预算控制，不直接出票 | `ndtchan/stock-picker-orchestrator` |

## 家族去重规则

- `tradingview-query`：`tvscreener` 与 `tradingview-screener` 属同族  
  raw 可以双记；family-adjusted 只能算 1 票
- `eastmoney-natural-language`：`mx-stocks-screener` 与 `em-stockpick` 属同族  
  如果问题几乎同义，只能算 1 票；若一个查 A 股、一个查港股，可分开记
- `validator` 家族：`stock-copilot-pro`、`yumstock`、`stock-evaluator-v3` 不直接创造 universe  
  只能对已有候选池给 `pass / reject / downgrade`

## 核心策略卡

### 1. `a-stock-picker`

- ClawHub ID：`danpian1/a-stock-picker`
- Role：`generator`
- Markets：`CN-A`
- Core principle：5 维等权量化初筛（市值 / MA15>MA60 / 换手 / MACD / 位置），通过 `>=3/5` 才进二层；二层再做基本面、行业、催化、筹码、龙头验证，最后给买点/止损/目标
- Best use：A 股主动选股、从大池子收敛到 3-5 只
- Main bias：中盘股偏好强；第二层人为判断多，不适合"完全自动化"
- Source note：ClawHub `inspect a-stock-picker`；registry snapshot `2026-05-29`

### 2. `mx-stocks-screener`

- ClawHub ID：`financial-ai-analyst/mx-stocks-screener`
- Role：`generator`
- Markets：`CN-A / HK / US / ETF / 基金 / 板块 / 可转债`
- Core principle：把自然语言条件翻译成东方财富妙想筛选条件，支持技术面、基本面、新闻面、情绪面和逻辑组合
- Best use：快速把一句模糊需求翻成全市场筛选表达式
- Main bias：更像数据检索器，不是自带 alpha；结果质量高度依赖 query 写法
- Source note：ClawHub `inspect mx-stocks-screener`；需要 `EM_API_KEY`

### 3. `iwencai-screener`

- ClawHub ID：`caobingxi/iwencai-screener`
- Role：`generator`
- Markets：`CN-A`
- Core principle：先从文本/链接里拆 3-5 个最核心受益方向，再逐个去 i问财抓每个方向前 5 个标的
- Best use：主题催化、产业链映射、新闻驱动选股
- Main bias：对"核心方向识别"很敏感；强主题时好用，纯财务筛选时不够硬
- Source note：ClawHub `inspect iwencai-screener`

### 4. `stock-select`

- ClawHub ID：`wanghl-cn/stock-select`
- Role：`generator`
- Markets：`CN-A`
- Core principle：自然语言条件选股 + Level2 主力净额/净量 + 集合竞价数据，可一直延伸到下单
- Best use：A 股短线和资金流主导的筛选
- Main bias：依赖 `Stockboot API`；如果没有 Token / Level2 权限，优势会明显削弱
- Source note：ClawHub `inspect stock-select`；外部依赖 `api.stockbot.me`

### 5. `yufeng-stock-screener`

- ClawHub ID：`wsy0303/yufeng-stock-screener`
- Role：`generator`
- Markets：`CN-A`
- Core principle：技术 40 / 资金 25 / 筹码 15 / 板块轮动 20 的云端评分框架，附 8 日加权择时
- Best use：A 股短线机会、强势股和主力资金驱动选股
- Main bias：时间窗短，天然偏 3-5 天；更像交易筛子，不适合作覆盖池长线建仓
- Source note：ClawHub `inspect yufeng-stock-screener`；依赖付费 Token

### 6. `zjtj-sar-quantum-strategy`

- ClawHub ID：`haohanyang92/zjtj-sar-quantum-strategy`
- Role：`generator`
- Markets：`CN-A`
- Core principle：四维同时满足才买入：ZJTJ 主力控盘、SAR 趋势翻多、放量验证、市场情绪不过冷
- Best use：A 股短线波段、规则型交易框架
- Main bias：强依赖通达信/ZJTJ 语义；在震荡市容易失灵
- Source note：ClawHub `inspect zjtj-sar-quantum-strategy`

### 7. `intellectia-stock-screener`

- ClawHub ID：`xanxustan/ai-screener`
- Role：`generator`
- Markets：`US / Crypto`
- Core principle：调用 Intellectia 预设的 Bullish/Bearish Tomorrow/Week/Month 列表，根据 `probability` 和 `profit` 排序
- Best use：短周期模式匹配、用外部 AI 预设先拿池子
- Main bias：黑箱程度较高；适合当外部信号源，不适合单独当结论
- Source note：OpenClaw tree 技能 `xanxustan/ai-screener`

### 8. `tvscreener`

- ClawHub ID：`subway-chenyan/tvscreener`
- Role：`generator`
- Markets：`CN-A / HK / US`
- Core principle：直接调 TradingView screener 字段，按 RSI、MACD、均线、量能、ATR、Bollinger 等字段自定义过滤
- Best use：快速规则筛选、查单个 symbol 的技术快照
- Main bias：强在字段筛选，不自带高阶解释；字段太多时容易变成"技术堆砌"
- Source note：OpenClaw tree 技能 `subway-chenyan/tvscreener`

### 9. `tradingview-screener`

- ClawHub ID：`hiehoo/tradingview-screener`
- Role：`generator`
- Markets：`GLOBAL`
- Core principle：TradingView API 预过滤 + pandas 计算信号 + YAML 驱动策略（golden cross、oversold bounce、volume breakout）
- Best use：做统一、可复用的可编排技术策略库
- Main bias：和 `tvscreener` 同族；如果同时使用，family-adjusted 只能算 1 票
- Source note：OpenClaw tree 技能 `hiehoo/tradingview-screener`

### 10. `banana-farmer`

- ClawHub ID：`adamandjarvis/banana-farmer`
- Role：`generator`
- Markets：`US / Crypto`
- Core principle：Ripeness score，把技术、价格动量、社交情绪压成单一 0-100 分，并给 `ripe / ripening / overripe / too-late` 标签
- Best use：趋势和情绪共振的热度筛选
- Main bias：天然偏 momentum；对低成交、冷门、长线基本面型标的不友好
- Source note：OpenClaw tree 技能 `adamandjarvis/banana-farmer`

### 11. `stock-analysis`

- ClawHub ID：`udiedrichsen/stock-analysis`
- Role：`generator`
- Markets：`US / Crypto`
- Core principle：Yahoo Finance 数据 + watchlist + hot scanner + rumor scanner，从热度、传闻和财报反应里找机会
- Best use：事件驱动、热点扩散、早期情绪信号
- Main bias：如果用户要求"共识票"，必须先限定使用哪一部分输出  
  推荐：只把 `stock_hot` 和 `stock_rumors` 的候选池计票，单票分析不计票
- Source note：OpenClaw tree 技能 `udiedrichsen/stock-analysis`

### 12. `stock-copilot-pro`

- ClawHub ID：`buxibuxi/stock-copilot-pro`
- Role：`validator`
- Markets：`CN-A / HK / US`
- Core principle：QVeris 多源 quote/fundamental/news/X sentiment 汇总，适合对 generator 选出的票做二次审查
- Best use：跨市场二次验证、事件雷达、单票对比
- Main bias：不是全市场初筛器，更适合做 gate
- Source note：OpenClaw tree 技能 `buxibuxi/stock-copilot-pro`

### 13. `yumstock`

- ClawHub ID：`yumyumtum/yumstock`
- Role：`validator`
- Markets：`US`
- Core principle：宏观门控优先，然后再看技术 35%、基本面 25%、宏观 40% 的复合分数
- Best use：当你担心"大环境错了，单票再好也不能重仓"时
- Main bias：天然是 gate，不适合拿来直接从全市场报 Top 10
- Source note：OpenClaw tree 技能 `yumyumtum/yumstock`

### 14. `stock-evaluator-v3`

- ClawHub ID：`demandgap/stock-evaluator`
- Role：`validator`
- Markets：`US`
- Core principle：极重的单票尽调仪表盘，包含 valuation、quality、technical、Piotroski/Altman/Beneish、persona scoring
- Best use：共识票跑出来以后，再用它做深度审单
- Main bias：太重，不适合作第一层 stock screen；默认只能 gate
- Source note：OpenClaw tree 技能 `demandgap/stock-evaluator`

## 非投票基础设施

### `a-share-real-time-data`

- ClawHub ID：`wangdinglu/a-share-real-time-data`
- Role：`data`
- 用途：A 股 bars、逐笔、实时 quote
- 规则：只补数，不计票

### `stock-picker-orchestrator`

- ClawHub ID：`ndtchan/stock-picker-orchestrator`
- Role：`meta`
- 用途：任务路由、预算、模块编排
- 规则：只编排，不计票

## 维护原则

- 有新 strategy 进来，先定 `role` / `vote_mode` / `family`
- 只有 `generator + direct` 默认进入共识矩阵
- `validator + gate` 只影响 pass/reject，不增加命中票数
- 引用外部 strategy 时，至少保留这 4 个出处字段：
  - `owner/slug`
  - snapshot date
  - source type（ClawHub inspect / GitHub source / local list）
  - external dependency（如 API key / Token / paid service）
