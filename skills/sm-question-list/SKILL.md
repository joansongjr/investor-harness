---
name: sm-question-list
description: 见分析师 / 管理层 / 产业专家之前，生成 question list 文件并触发 vault 扫描，每个问题下面自动附"vault 扫描初步结论"——交叉综合现有的所有纪要、研报、公众号、模型数据，列出当前知识库已经能回答的部分、已知的矛盾点、以及建议的追问方向。打印出来就是完整的会前 briefing。v0.7.0 新增。
inputs:
  - ticker / 公司名
  - 会议类型（业绩交流 / 实地调研 / 产业专家 / 路演）
  - 问题列表（可选，没给的话用模板自动生成 6 模块 ~20 问）
outputs:
  - vault/{ticker}/question-list-{YYYY-MM-DD}.md
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
trigger: 用户明示"见 XX 前过一遍 question list / 准备调研提纲"
---

# SM Question List

**Librarian 模式 skill**。机制最大的副作用：**vault 扫描经常会主动纠正你的认知偏差**——你以为的数字和 vault 里实际能找到的数字经常有出入。系统把两个数字摆在一起，矛盾立刻暴露——这种纠正如果在会上才发生，代价就大了。

## 强制流程

> ⛔ 先读 [`../../core/qa-double-link.md`](../../core/qa-double-link.md) 双链机制
> ⛔ 输出前按 [`../../core/postamble.md`](../../core/postamble.md)

## 模板：6 模块 question list

1. **基本面验证**：上次电话会指引 vs 这次实际，deliver/miss 的方向
2. **竞争格局**：市占率、关键产品定价、客户结构变化
3. **运营节奏**：CapEx 投放、产能爬坡、海外扩张时点
4. **财务质量**：毛利率结构、应收应付变化、现金流匹配
5. **催化剂**：管理层提到的未来 6-12 个月时间节点
6. **风险与反方**：当前认为的最大短板、市场看错的地方

## 每个问题下的"vault 扫描初步结论"必填

```
Q1: FY26 出海销量目标？
  vault 已知：
  - [[20260315 FY25 全年电话会]] 提 30k 单位（B 级 - 管理层口径）
  - [[20260410 GS NVDA]] 推算 28k 单位（B 级 - 卖方推算）
  - [[model FY26]] 当前假设 32k 单位（A 级 - 财报披露 + 自己模型）
  矛盾点：管理层口径 30k vs 模型 32k，差 6.7%
  建议追问：32k 的差额是否来自下半年新客户？哪些已签 LOI？
```

## 验收

- [ ] 每问都带"vault 已知 + 矛盾点 + 建议追问"
- [ ] 矛盾点统一标差异百分比（不是定性"有差异"）
- [ ] 文件名带日期，方便会后归档时找到这份
- [ ] 末尾留一段"会上要确认的判断点"（PM 视角）
