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

## 开始前先取数

按 [../../core/adapters.md](../../core/adapters.md) 的数据获取协议取数。Thesis 阶段数据需求最轻——只需要对标的有基本认知即可。如果连基本认知都没有，先走 `sm-company-deepdive` 或 `sm-industry-map`。

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
