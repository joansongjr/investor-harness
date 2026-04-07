---
name: sm-batch-earnings
description: 财报季批量前瞻 / 复盘 skill。用于在一周或一个财报季内批量产出多家覆盖标的的财报前瞻或财报后复盘，按发布日期排序，统一输出格式，方便分析师团队在密集财报季高效响应。
inputs:
  - 时间窗（如"下周"、"2026-Q1 财报季"）
  - 可选：标的范围（覆盖池子集 / 行业 / 全量）
  - 可选：模式（preview 前瞻 / postmortem 复盘）
outputs:
  - 按发布日期排序的批量财报报告
  - 每家公司的标准前瞻或复盘
  - 总体行业财报季节奏摘要
data_sources: 见 ../../core/adapters.md
markets: [CN-A, HK, US]
---

# SM Batch Earnings

这个 skill 用于**财报季的批量前瞻或复盘**——分析师团队在财报季最痛的时间窗。

## 强制流程（v0.3 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 5 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 6 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检
>
> **跳过任何一环视为未完成任务。**

Batch Earnings 特别注意：每家公司的子任务必须**完整调用 `sm-earnings-preview`** 的逻辑，不能简化。preamble Step 4 必须先列出本次时间窗内的全部财报日历。

## 适用场景

- **财报季前一周**：批量产出本周所有覆盖标的的前瞻
- **财报季中**：每天复盘前一日发布的多家结果
- **财报季后**：整合一个完整财报季的命题验证

## 工作流程

### 第一步：拉取财报日历

通过 iFind 或公司公告，拉出指定时间窗内的全部财报发布日：

```
[Earnings Calendar 2026-04-07 ~ 2026-04-14]
| 日期 | Ticker | 名称 | 类型 |
|---|---|---|---|
| 2026-04-08 | 688256 | 寒武纪 | Q1 财报 |
| 2026-04-10 | 0700 | 腾讯控股 | Q1 业绩会预告 |
| 2026-04-12 | NVDA | NVIDIA | FY26 Q1 |
```

### 第二步：按公司逐个跑完整 sm-earnings-preview

对每家公司：
- 调 `sm-earnings-preview` 完整流程
- 输出按 sm-earnings-preview 的结构
- 单家归档到 `{coverage_root}/{ticker}/earnings/{YYYY-QN}-preview.md`

### 第三步：生成总体节奏摘要

在每家完成后，汇总成一份"财报季节奏摘要"：

```markdown
# Batch Earnings Preview · {Date Range}

## 本期覆盖
- N 家公司，按发布日期排序

## 行业层面观察
- AI 算力链：{X 家中 Y 家有上修指引可能}
- 半导体：{Z 家面临折旧压力高点}
- 新能源：{W 家受益储能放量}

## 高优先级关注
- 🔴 {ticker}：{为什么是高优先级}
- 🟡 {ticker}：{为什么}

## 各家详细前瞻链接
- [688256 寒武纪 Q1 Preview](coverage/688256_寒武纪/earnings/2026-Q1-preview.md)
- [688981 中芯国际 Q4 Preview](coverage/688981_中芯国际/earnings/2026-Q4-preview.md)
- ...
```

### 第四步（可选）：复盘模式

如果是 postmortem 模式，对每家发布后的公司：
- 实际 vs 一致预期
- 实际 vs 你的 preview
- 对原 thesis 的影响
- 是否需要触发 sm-thesis update

## 输出验收（除通用清单外）

- [ ] 财报日历完整且按日期排序
- [ ] 每家公司的 preview / postmortem 都通过 sm-earnings-preview 的专属验收清单
- [ ] 行业层面观察非空
- [ ] 高优先级标的有显式标注
- [ ] 所有子输出已写入对应 ticker 目录

## 与其他 skill 的协作

- **每家 preview 内部**：触发 `sm-consensus-watch` 拿一致预期
- **postmortem 后**：如果实际显著偏离 preview → 触发 `sm-thesis update`
- **若高优先级**：自动建议跑 `sm-pm-brief` 给 PM 一页纸
- **批量收尾**：自动建议跑 `sm-briefing` 整合成晨会要点

## 性能与节流

- 大批量任务（>10 家）建议拆批执行
- 在 active-tasks.md 记录"批次进度"，断点续做
- 单次会话不超过 20 家，超过分多个会话

## 参考

- [../../core/preamble.md](../../core/preamble.md)
- [../../core/postamble.md](../../core/postamble.md)
- [../../core/output-archive.md](../../core/output-archive.md)
- [../../core/acceptance.md](../../core/acceptance.md)
- [../sm-earnings-preview/SKILL.md](../sm-earnings-preview/SKILL.md)
