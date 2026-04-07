---
name: sm-consensus-watch
description: 一致预期与预期差管理 skill。用于判断市场已 price in 的内容、被低估或高估的变量、盈利与估值的偏差来源，以及哪些边际变化可能带来股价重估。适合财报季、估值切换和预期差挖掘。
inputs:
  - 公司名 / 行业
  - 可选：卖方一致预期、市场观点、公司指引
outputs:
  - 预期差矩阵与验证节点
data_sources: 见 ../../core/adapters.md
markets: [CN-A, HK, US]
---

# SM Consensus Watch

这个 skill 用于研究"市场在想什么"以及"市场可能错在哪"。

## 开始前先取数

按 [../../core/adapters.md](../../core/adapters.md) 的数据获取协议取数，按 [../../core/markets.md](../../core/markets.md) 确认标的市场。一致预期类任务需要重点获取卖方一致预期（iFind `get_stock_performance` 或卖方研报摘要），缺这层数据时请明确告知用户"无法判断预期差"并走兜底。

## 核心任务

- 识别市场共识
- 判断哪些变量已被定价
- 找出边际变化
- 分析预期差对盈利、估值和仓位的影响

## 输出格式

- `市场共识`
- `已 price in 的内容`
- `可能未充分反映的变量`
- `预期差成立条件`
- `对盈利预测 / 估值锚 / 仓位讨论的影响`
- `最关键验证节点`

## 约束

- 不要把"我觉得"当作共识
- 不要脱离时间窗口谈预期差
- 尽量写清比较基准和估值语境
- 市场共识标 `M1`，被低估变量的支撑证据标 `F1`/`F2`

## 参考

- [../../core/evidence.md](../../core/evidence.md)
- [../../core/templates.md](../../core/templates.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/adapters.md](../../core/adapters.md)
