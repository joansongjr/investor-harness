---
name: sm-briefing
description: 晨会、晚报、调研纪要和路演提纲整理 skill。用于把零散信息整理成适合投研团队和基金经理阅读的结构化摘要，并明确最重要的事项、覆盖池影响和待跟踪问题。
inputs:
  - 零散材料（新闻、纪要、公告、路演记录）
  - 可选：覆盖池清单
outputs:
  - 晨会/晚报结构化摘要
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
---

# SM Briefing

这个 skill 用于把材料整理成投研团队能直接使用的摘要。

## 开始前先取数

按 [../../core/adapters.md](../../core/adapters.md) 的数据获取协议取数，按 [../../core/markets.md](../../core/markets.md) 确认相关市场。Briefing 场景通常需要拉近 24 小时内的资讯（iFind `search_trending_news` / cn-web-search / WebSearch）。

适用场景：

- 晨会要点
- 收盘复盘
- 调研纪要
- 路演摘要
- 问题清单

## 默认输出格式

- `今日最重要的三件事`
- `对覆盖池 / 组合的影响`
- `最值得跟踪的公司或方向`
- `待回答问题`
- `一句话给基金经理`

如果用户要调研提纲，改为输出：

- `调研目的`
- `必问问题`
- `不同回答分别意味着什么`

## 参考

- [../../core/templates.md](../../core/templates.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/adapters.md](../../core/adapters.md)
