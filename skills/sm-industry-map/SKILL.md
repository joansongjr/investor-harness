---
name: sm-industry-map
description: 二级市场行业框架与产业链拆解 skill。用于构建行业研究框架、供需逻辑、价格传导、竞争格局、关键公司地图和当前市场争议点。适合行业深度、主线梳理和赛道筛选。
inputs:
  - 行业 / 主题名称
  - 可选：已有研究材料、产业链初步认知
outputs:
  - 行业框架图 + 关键公司地图 + 跟踪指标
data_sources: 见 ../../core/adapters.md
markets: [CN-A, HK, US, GLOBAL]
---

# SM Industry Map

这个 skill 用于行业和赛道层面的研究框架搭建。

## 开始前先取数

按 [../../core/adapters.md](../../core/adapters.md) 的数据获取协议取数。行业研究需要：产业链代表公司清单（iFind `search_stocks` 按主题筛）+ 行业指标（iFind `get_edb_data` 宏观/行业指标）+ 行业报告与政策 (cn-web-search / WebSearch)。

适用场景：

- 行业深度
- 赛道梳理
- 主题投资主线判断
- 周期与景气跟踪

## 输出重点

- 产业链地图
- 需求驱动因素
- 供给格局
- 价格与利润传导机制
- 关键公司定位
- 当前争议点和预期差来源

## 输出格式

- `行业一句话判断`
- `产业链结构`
- `需求侧驱动`
- `供给侧变化`
- `价格 / 利润传导`
- `重点公司与分工`
- `当前市场争议点`
- `最值得跟踪的行业指标`

## 约束

- 不要只列公司名单
- 不要把宏观背景写得过长
- 最终要落到"谁受益、谁受损、何时验证"

## 参考

- [../../core/workflows.md](../../core/workflows.md)
- [../../core/evidence.md](../../core/evidence.md)
- [../../core/templates.md](../../core/templates.md)
- [../../core/adapters.md](../../core/adapters.md)
- [../../core/markets.md](../../core/markets.md)
