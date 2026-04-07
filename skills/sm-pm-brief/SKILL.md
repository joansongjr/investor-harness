---
name: sm-pm-brief
description: 面向基金经理或投资决策会的一页纸摘要 skill。用于把复杂研究压缩成高密度、可决策的短结论，突出为什么现在看、市场错在哪、核心催化、主要风险和下一步行动。
inputs:
  - 前置研究结论或多份研究材料
outputs:
  - 一页纸决策摘要
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
---

# SM PM Brief

这个 skill 用于把研究结论压缩成决策材料。

## 开始前先取数

按 [../../core/adapters.md](../../core/adapters.md) 的数据获取协议取数。PM Brief 通常在前置研究之后运行，数据需求较少——但若用户直接从 PM Brief 入手，仍需先补齐基础数据。

## 输出原则

- 短
- 硬
- 可决策
- 少背景，多判断

## 输出格式

- `结论`
- `为什么现在看`
- `市场可能错在哪`
- `最关键催化`
- `最大风险`
- `建议下一步`

## 约束

- 避免大段背景复述
- 避免使用不带边界的形容词
- 写清时间窗口和假设前提
- 涉及评级或目标价必须提醒人工复核

## 参考

- [../../core/templates.md](../../core/templates.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/adapters.md](../../core/adapters.md)
