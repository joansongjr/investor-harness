---
name: sm-thesis
description: 二级市场投资命题拆解 skill。用于把模糊想法收敛成可验证的投资命题，识别核心矛盾、股价驱动、成立条件、证伪路径与优先跟踪指标。适合在决定"这条主线值不值得研究"时使用。
inputs:
  - 模糊的研究方向 / 公司名 / 主题
outputs:
  - 投资命题 + 成立条件 + 跟踪指标
data_sources: 见 ../../core/adapters.md
markets: [CN-A, HK, US, GLOBAL]
---

# SM Thesis

这个 skill 用于投研工作的第一步：把题目从"一个方向"压缩成"一个可验证的投资命题"。

## 强制流程（v0.3 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 5 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 6 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检
>
> **跳过任何一环视为未完成任务。**

Thesis 特别注意：数据需求最轻，但 preamble Step 2 必须检查是否有同标的的历史 deepdive / industry-map 输出。如果连基本认知都没有，先走 `sm-company-deepdive` 或 `sm-industry-map`。

适用场景：

- "这个方向值不值得看"
- "这家公司为什么现在值得研究"
- "市场到底在交易什么"
- "股价最核心的驱动变量是什么"

## 工作方式

默认按以下步骤输出：

1. 定义命题
2. 识别核心矛盾
3. 拆解命题成立的必要条件
4. 说明当前市场预期可能错在哪
5. 给出证伪路径和跟踪指标

## 输出格式

- `一句话命题`
- `核心矛盾`
- `股价驱动变量`
- `命题成立的三个必要条件`
- `市场可能忽略的点`
- `证伪点`
- `未来一个月最该跟踪的三项数据`

## 约束

- 不要直接给出武断结论
- 不要把信息堆砌当成逻辑
- 明确区分事实、预期和推演

## 参考

- [../../core/evidence.md](../../core/evidence.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/templates.md](../../core/templates.md)
- [../../core/adapters.md](../../core/adapters.md)
