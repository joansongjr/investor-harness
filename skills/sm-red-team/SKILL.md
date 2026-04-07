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

## 开始前先取数

按 [../../core/adapters.md](../../core/adapters.md) 的数据获取协议取数。Red Team 需要用户先给出多头逻辑，然后主动去找反方证据——重点查：历史类似案例（WebSearch）、行业周期拐点信号 (iFind `get_edb_data`)、空头观点（研报、论坛）。

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
