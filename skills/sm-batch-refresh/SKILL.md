---
name: sm-batch-refresh
description: 覆盖池批量刷新 skill。用于按周/月节奏批量更新覆盖公司的最新行情、财务、股东、催化剂等关键数据，并自动写入每家公司的归档目录。适合分析师团队维护几十到几百家覆盖标的。
inputs:
  - 覆盖池清单（默认从 coverage_root/INDEX.md 读取）
  - 可选：刷新范围（全量 / 子赛道 / 单家）
  - 可选：刷新维度（全部 / 行情 / 财务 / 股东 / 催化剂）
outputs:
  - 每家标的的批量更新摘要
  - 失败标的清单 + 原因
  - 总体覆盖池健康度报告
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US]
---

# SM Batch Refresh

这个 skill 用于**批量维护覆盖公司池**——分析师团队最高频但最枯燥的工作。

## 强制流程（v0.3 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 5 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 6 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检
>
> **跳过任何一环视为未完成任务。**

Batch Refresh 特别注意：preamble Step 4 的 [Preflight] 必须列出本次刷新的标的清单 + 维度 + 预计的工具调用次数，确保用户知道这是大批量任务。

## 适用场景

- **每周一早晨**：刷新全部覆盖池的行情、本周公告、本周新闻
- **每月第一个工作日**：刷新所有公司的财务指标 + 股东结构
- **每季度财报季前**：批量预拉财报披露日历
- **临时全扫**：行业事件后批量看影响（"美国限令更新，扫一遍 AI 算力链"）

## 核心任务

1. **读取覆盖池清单**：从 `{coverage_root}/INDEX.md` 拉全部 ticker
2. **筛选范围**：按用户指定（全量 / 子赛道 / 个别）筛
3. **逐个执行**：对每个 ticker 调用对应的取数工具
4. **自动归档**：每家更新写入 `{coverage_root}/{ticker}_{name}/data/{YYYY-MM-DD}-refresh.md`
5. **生成总报告**：汇总成功 / 失败 / 显著变化

## 输出格式

### 总体摘要

```markdown
# Batch Refresh · {YYYY-MM-DD}

**范围**：{全量 82 家 / 光模块子赛道 22 家 / ...}
**维度**：{行情+公告+新闻 / 全部财务字段 / ...}
**用时**：{X 分钟}

## 摘要
- ✅ 成功更新：N 家
- ⚠️ 部分成功：M 家
- ❌ 失败：K 家

## 显著变化（关注点）

| Ticker | 名称 | 变化类型 | 详情 |
|---|---|---|---|
| 688256 | 寒武纪 | 重大公告 | 新增订单合同 (F2) |
| 688981 | 中芯国际 | 财务异常 | Q4 毛利率超预期 (F2) |

## 失败清单

| Ticker | 名称 | 失败原因 |
|---|---|---|
| {ticker} | {name} | iFind 超时 / 数据未披露 |
```

### 每家标的的更新明细（写入 data/ 目录）

```markdown
# {ticker} {name} · Refresh {YYYY-MM-DD}

## 行情快照
- 收盘价 / 周涨跌 / 月涨跌 / YTD (F2-iFind)

## 财务最新
- 最近一期 PE / PB / PS / ROE (F2-iFind)
- 营收 / 净利 / 毛利率 同比 (F2-iFind)

## 股东变化
- 十大股东最新一期 (F2-iFind)
- 与上一期对比 (C1)

## 本周公告 / 新闻
- {公告 1} (F2)
- {新闻 1} (M1)

## 自动告警
- ⚠️ 任何"显著变化"必须在这里标出（毛利率突变、股东大幅减持、重大公告等）

## 仍需补的资料
- {缺失项}
```

## 批量执行的最佳实践

### 节流
- 每个 ticker 之间至少 200ms 间隔，避免触发数据源 rate limit
- iFind MCP 单次会话最多 100 个 query，超过分批

### 失败重试
- 任何 ticker 失败立即记入失败清单，**不要中断整个批量任务**
- 全部跑完后统一汇报失败

### 增量更新
- 对比上次 refresh 的快照，**只输出有变化的字段**
- 避免每次都把全部数据重写一遍

### 任务持久化
- 长批量任务必须支持中断恢复
- 在 active-tasks.md 里记录"已完成 N/总 M"，断点继续

## 与其他 skill 的协作

- **触发深度研究**：如果某只标的检测到"显著变化"，**自动**触发 `sm-catalyst-monitor` 单点分析
- **触发反方审视**：如果某只标的本周涨幅超过 20%，**自动建议**走 `sm-red-team`
- **触发命题更新**：如果财务数据与上一份 thesis 假设矛盾，**主动提醒**用户跑 `sm-thesis` update

## 输出验收（除通用清单外）

- [ ] 已列出本次刷新的标的清单
- [ ] 每个标的有"更新的字段"摘要
- [ ] 失败的标的明确列出原因
- [ ] 显著变化已标注并触发后续 skill 建议

## 参考

- [../../core/preamble.md](../../core/preamble.md)
- [../../core/postamble.md](../../core/postamble.md)
- [../../core/output-archive.md](../../core/output-archive.md)
- [../../core/acceptance.md](../../core/acceptance.md)
- [../../core/evidence.md](../../core/evidence.md)
- [../../core/compliance.md](../../core/compliance.md)
