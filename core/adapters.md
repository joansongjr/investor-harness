# Data Adapters

所有 sm-* skills 在开始输出前，先按本文件的"数据获取协议"拿数据，再进入各自的分析流程。

这是**建议模式**的决策树：给出优先级和判断条件，但不强制写死调用参数，允许 LLM 根据当前任务灵活选择。

---

## 总原则

1. **先确认任务的市场归属**（A 股 / 港股 / 美股 / 跨市场），参见 [markets.md](markets.md)
2. **按优先级探测可用数据源**：MCP 工具 → skill 工具 → 通用搜索 → 兜底
3. **拿到什么数据就标什么证据等级**（见 [evidence.md](evidence.md)）
4. **数据不足时不要编造**，先走兜底流程让用户补

---

## 数据源优先级（通用决策树）

```
Step 1 — 判断标的市场
│
├── A 股 / 公募 → 跳 §A
├── 港股       → 跳 §H
├── 美股       → 跳 §U
└── 跨市场 / 行业主题 → §A + §H + §U 并行

Step 2 — 按市场分支获取数据

Step 3 — 若全部失败 → 走"兜底协议"
```

---

## §A — A 股 / 公募基金

**优先级 1：iFind MCP（同花顺官方数据）**

检测方式：工具命名空间存在 `hexin-ifind-ds-*`

- 公司层：`get_stock_summary`, `get_stock_performance`, `get_stock_financials`, `get_stock_info`, `get_stock_shareholders`, `get_risk_indicators`, `get_stock_events`, `get_esg_data`
- 行业 / 选股：`search_stocks`
- 基金：`search_funds`, `get_fund_profile`, `get_fund_portfolio`, `get_fund_market_performance`, `get_fund_ownership`
- 宏观：`get_edb_data`, `search_edb`
- 资讯 / 公告：`search_notice`, `search_news`, `search_trending_news`

调用约定：
- 所有 `query` 参数使用**中文自然语言**，包含证券名称/代码 + 指标名 + 时间范围
- 财务指标用报告期：`2025-12-31`、`2025-06-30`
- 选股条件不要过于宽泛，资讯 size 上限 20

**优先级 2：cn-web-search skill**

检测方式：用户环境中存在 `cn-web-search` skill 或等效工具

典型查询：
- `{公司名} 年报 2024`
- `{公司名} 产业链地位`
- `{公司名} 一致预期`
- `{行业} 景气度 2025`

**优先级 3：WebSearch（通用兜底）**

所有主流 harness 都支持。典型查询：
- `{公司名} 财报 site:cninfo.com.cn`
- `{公司名} 公告 site:sse.com.cn OR site:szse.cn`

**优先级 4：让用户贴材料**（走"兜底协议"）

---

## §H — 港股

**优先级 1：cn-web-search skill**（如果可用）
- `{公司名} 业绩 HKEX`
- `{公司名} 通告`

**优先级 2：WebFetch 直取 HKEX 官网**
- `https://www.hkexnews.hk/` 搜索公告
- `https://www.hkex.com.hk/` 公司页面

**优先级 3：WebSearch**
- `{stock name} annual report hkex`
- `{股票代码} 港股 公告`

**优先级 4：兜底协议**

---

## §U — 美股

**优先级 1：WebSearch + SEC EDGAR**
- `{ticker} 10-K site:sec.gov`
- `{ticker} 10-Q site:sec.gov`
- `{company name} earnings transcript`

**优先级 2：WebFetch SEC EDGAR 直取**
- `https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK={ticker}`

**优先级 3：其他公开财经源**（WSJ、Reuters、Bloomberg 摘要、公司 IR 页）

**优先级 4：兜底协议**

---

## 跨市场 / 行业主题

例如 "全球动力电池供给" 这类题目：

1. 先用 `sm-industry-map` skill 的框架搭产业链
2. 按"核心玩家清单"拆解到各自市场（§A/§H/§U）
3. 并行拉数据，最后在同一个证据表里汇总

---

## 兜底协议（所有市场通用）

当上述优先级全部不可用时：

1. **停下来**，不要开始分析
2. 按下面模板回复用户：

```
我当前无法直接获取 {公司/行业/主题} 的数据。要继续，需要你提供：

必需（至少选一项）：
- 最新年报 / 季报（PDF 或关键财务指标文本）
- 近一个季度的公司公告或新闻
- 你对标的的现有观点、材料、或研究笔记

可选（提高分析质量）：
- 可比公司清单
- 你关心的关键变量
- 时间窗口（近期事件 vs. 长期逻辑）

贴完后我会按 sm-{current-skill} 的标准流程输出。
```

3. 拿到材料后才开始正式流程，并在输出的"仍需补的资料"一栏列出仍缺的项。

---

## 对 LLM 的行为要求

- **不要**猜数据。缺数据就走兜底或降级到下一优先级
- **不要**混合真假数据。比如用一个工具拿到的数据和自己推演的数字放在一起而不标注
- **要**在输出开头一行注明本次分析的数据来源（例：`数据来源：iFind MCP + 用户提供资料`）
- **要**为每条关键事实打证据等级标签（F1/F2/M1/C1/H1）
- **要**在"仍需补的资料"一栏列出未能获取的关键项

---

## 新增数据源时怎么办

如果未来接入新的 MCP 或工具（例如 Wind MCP、Bloomberg API），只需要：

1. 在本文件对应 §A/§H/§U 段落里插入新的优先级条目
2. 不需要修改任何 skill 文件
3. 发布 patch 版本

这就是 adapter 层抽离的核心价值——**数据源变化不影响方法论**。
