---
name: sm-catalyst-sweep
description: 覆盖池每日 / 每周催化剂扫描 skill。用于在固定时间窗内扫描全部覆盖标的的公告、新闻、政策、价格异动等催化剂信号，按重要性分级并关联到具体标的。适合做晨会前批量扫描和持仓异动监控。
inputs:
  - 时间窗（默认 24 小时）
  - 可选：标的范围（默认全覆盖池）
  - 可选：催化剂类型筛选（公告 / 新闻 / 价格异动 / 政策）
outputs:
  - 按重要性分级的催化剂清单
  - 每条催化剂关联到具体 ticker 和影响判断
  - 高优先级催化剂的后续 skill 调用建议
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
---

# SM Catalyst Sweep

这个 skill 用于**批量扫描覆盖池的所有催化剂信号**——分析师晨会前最该跑一次。

## 强制流程（v0.3 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 5 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 6 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检
>
> **跳过任何一环视为未完成任务。**

Catalyst Sweep 特别注意：preamble Step 4 必须明确时间窗（默认过去 24 小时），并按"覆盖池 → 子赛道 → 全市场"三层依次扫描。

## 适用场景

- **每日晨会前 30 分钟**：扫一遍覆盖池过去 24 小时的所有催化
- **重大事件后**：扫一遍受影响的子赛道（"美国对华出口管制更新，扫一遍 AI 算力链"）
- **每周一早晨**：扫上周末的政策、产业新闻、海外动态
- **持仓异动告警**：股价异常变动后追溯催化原因

## 工作流程

### 第一步：定义扫描范围

```
[Preflight - Sweep]
时间窗：{2026-04-06 09:00 ~ 2026-04-07 09:00}
标的范围：覆盖池 82 家
催化类型：公告 / 新闻 / 价格异动 / 政策
预计调用：iFind search_notice (82 次) + search_trending_news (按子赛道)
```

### 第二步：分类型扫描

**类型 A：公司层公告**
- 对每家覆盖标的调 `iFind.search_notice query="{name} 最近24小时公告"`
- 命中的写入候选清单

**类型 B：行业 / 政策新闻**
- 按子赛道调 `iFind.search_trending_news query="{sector} 今日热点"`
- 国家级政策调 `WebSearch site:gov.cn` 或新华社

**类型 C：价格异动**
- 调 `iFind.get_stock_performance` 拿覆盖池涨跌幅
- 标记 |变动| > 5% 的标的

### 第三步：按重要性分级

每条命中按以下标准打分：

| 级别 | 标准 | 处理 |
|---|---|---|
| 🔴 高 | 直接影响盈利预测的事件（重大合同、业绩预告、监管处罚） | 必须人工立即看 + 触发 sm-catalyst-monitor |
| 🟡 中 | 影响估值或叙事的事件（政策变化、行业数据） | 写入晨会要点 |
| 🟢 低 | 仅作为背景信息（一般新闻、例行公告） | 归档到 catalyst-log |

### 第四步：输出总扫描报告

```markdown
# Catalyst Sweep · {YYYY-MM-DD HH:MM}

**时间窗**：过去 24 小时
**覆盖范围**：82 家覆盖标的 + 5 个行业 + 政策面
**总命中**：N 条事件

## 🔴 高优先级（M 条）

### 1. {ticker} {name} - {事件标题}
- **类型**：业绩预告 / 重大合同 / 监管 / ...
- **影响方向**：⬆️ / ⬇️ / 中性
- **影响路径**：{一句话说明对哪个变量的影响}
- **建议下一步**：调 sm-catalyst-monitor 做深度分析
- **证据**：F2 - {链接}

### 2. ...

## 🟡 中优先级（K 条）

| Ticker | 名称 | 事件 | 影响方向 | 证据 |
|---|---|---|---|---|
| ... | ... | ... | ⬆️/⬇️ | F2 |

## 🟢 低优先级（J 条 - 仅归档）

[折叠列表]

## 行业级观察

- {子赛道 1}：{今日整体情绪/事件}
- {子赛道 2}：{今日整体情绪/事件}

## 政策面

- {国家级政策 1}
- {国家级政策 2}

## 价格异动 Top 5

| Ticker | 涨跌幅 | 原因（如已知） |
|---|---|---|
| ... | +X% | ... |
```

## 与其他 skill 的协作

- **🔴 高优先级标的** → **自动建议**调 `sm-catalyst-monitor` 做单事件深度
- **行业级共振** → **自动建议**调 `sm-industry-map update`
- **多个高优先级** → **自动建议**调 `sm-briefing` 整合成晨会要点
- **价格异动 Top 1-2** → **自动建议**调 `sm-red-team` 检查多空逻辑

## 输出验收（除通用清单外）

- [ ] 时间窗明确（具体到小时）
- [ ] 命中事件按 高/中/低 三级分类
- [ ] 每条命中关联具体 ticker（不能是"行业利好"）
- [ ] 价格异动 Top 5 已附
- [ ] 高优先级事件都给出"建议下一步" skill

## 性能与节流

- 全量扫 82 家公告 + 行业新闻约需 5-8 分钟
- 节流：每个 query 之间 200ms
- 失败的标的记入失败清单，不中断扫描
- 进度写入 active-tasks.md

## 与 sm-batch-refresh 的区别

| 维度 | sm-catalyst-sweep | sm-batch-refresh |
|---|---|---|
| **频率** | 每日（24h 时间窗） | 每周/每月 |
| **重点** | 事件 / 催化 / 异动 | 财务 / 行情 / 股东 |
| **输出** | 行动导向（建议下一步） | 数据导向（更新数据） |
| **协作** | 触发 sm-catalyst-monitor | 触发 sm-thesis update |

两者互补，建议都跑。

## 参考

- [../../core/preamble.md](../../core/preamble.md)
- [../../core/postamble.md](../../core/postamble.md)
- [../../core/output-archive.md](../../core/output-archive.md)
- [../../core/acceptance.md](../../core/acceptance.md)
- [../sm-catalyst-monitor/SKILL.md](../sm-catalyst-monitor/SKILL.md)
- [../sm-briefing/SKILL.md](../sm-briefing/SKILL.md)
