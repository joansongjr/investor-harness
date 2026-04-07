---
name: sm-red-team
description: 二级市场反方论证与证伪 skill。用于对现有多头逻辑做空头审视，识别脆弱假设、证据断层、可能踩空的变量、替代标的和最早暴露错误的数据点，帮助降低单边叙事风险。
inputs:
  - 现有多头逻辑（结论 + 支撑证据）
  - 可选：公司或行业材料
outputs:
  - 空头审视报告与证伪路径
data_sources: 见 ../../core/adapters.md
markets: [CN-A, HK, US]
---

# SM Red Team

这个 skill 专门负责"唱反调"，目的是降低确认偏误。

## 强制流程（v0.3 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 5 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 6 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检
>
> **跳过任何一环视为未完成任务。**

Red Team 特别注意：preamble Step 4 的取数必须包含历史类似案例 + 行业周期拐点信号 + 空头观点 3 类。**强制读取用户的 `biases.md` 文件**并在结论中显式报告命中情况——这是 Red Team 区别于其他工具的核心。

适用场景：

- 多头逻辑太顺时
- 准备提交正式观点前
- 财报前或建仓前
- 市场高度一致时

## 输出格式

- `多头逻辑最脆弱的三个假设`
- `哪些证据目前还不够`
- `若结论错误，最早会暴露在哪里`
- `哪些数据出现后应下修观点`
- `更好的替代标的 / 替代方向`
- `当前结论的可信度评估`

## 约束

- 风险必须尽量可观测、可触发
- 不要只写套话式风险
- 必须指向具体变量、数据或时间点

## 参考

- [../../core/evidence.md](../../core/evidence.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/adapters.md](../../core/adapters.md)
