---
name: sm-company-deepdive
description: 二级市场公司深度研究 skill。用于拆解公司商业模式、收入利润驱动、产业链位置、竞争壁垒、关键客户、财务弹性和未来三个月跟踪指标。适合覆盖启动、公司更新和财报前准备。
inputs:
  - 公司名 / 股票代码
  - 可选：研究材料、年报、纪要、卖方摘要
outputs:
  - 公司深度跟踪卡（9 段）
data_sources: 见 ../../core/adapters.md
markets: [CN-A, HK, US]
---

# SM Company Deepdive

这个 skill 用于公司层面的深度研究，不写空泛概述，要尽量回答"为什么是这家公司，而不是别人"。

## 开始前先取数

按 [../../core/adapters.md](../../core/adapters.md) 的数据获取协议取数，并按 [../../core/markets.md](../../core/markets.md) 确认标的市场。本 skill 是最吃数据的 skill，缺数据时严禁开始输出结论。

适用场景：

- 覆盖启动
- 公司更新
- 财报前准备
- 可比公司比较

## 必答问题

- 公司在产业链里的位置是什么
- 收入增长靠什么驱动
- 利润弹性来自哪里
- 市场当前为什么关注它
- 与同行相比真正不同的地方是什么
- 下一个验证节点是什么

## 输出格式

- `公司定位`
- `业务拆分`
- `收入驱动`
- `利润驱动`
- `核心竞争力 / 风险点`
- `市场关注焦点`
- `与可比公司的关键差异`
- `未来三个月跟踪指标`
- `仍需补的资料`

## 约束

- 没有证据时，不要假设客户、订单或份额变化
- 避免把管理层表述直接当成事实
- 优先突出影响盈利和估值的变量
- 关键事实必须带证据等级（F1/F2/M1/C1/H1）

## 参考

- [../../core/evidence.md](../../core/evidence.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/templates.md](../../core/templates.md)
- [../../core/adapters.md](../../core/adapters.md)
- [../../core/markets.md](../../core/markets.md)
