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

## 强制流程（v0.3 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 5 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 6 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检
>
> **跳过任何一环视为未完成任务。**

PM Brief 特别注意：preamble Step 2 必须读取该公司**所有最近的相关 skill 输出**（thesis / deepdive / consensus / red-team / earnings）作为输入。PM Brief 的价值就是整合，没有前置研究等于没法做。

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
