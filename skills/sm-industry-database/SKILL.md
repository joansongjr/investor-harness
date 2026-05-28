---
name: sm-industry-database
description: 产业数据库搭建 skill。用于把公开市场数据、公司披露、卖方报告、行业数据库（如 EDB / iFind EDB / 第三方产业库）整理成可追溯的 Excel 数据库，既支持产业数据库，也支持公司数据库、指标库和长期跟踪底表。
inputs:
  - 行业 / 赛道 / 公司 / 指标范围
  - 可选：时间跨度、市场范围、现有字段清单、已有 Excel 底表
outputs:
  - Excel 数据库主文件（.xlsx）
  - 同名归档说明（.md）
  - 缺口清单与刷新建议
data_sources:
  - 见 ../../core/adapters.md
  - 公司公告 / 年报 / 业绩会材料
  - 卖方报告（仅作内部数据库来源，不直接等同于外发可引事实）
  - 行业数据库 / EDB / iFind EDB / 第三方产业库
  - 公开市场价格与成交数据
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
trigger: 用户明示“数据库 / 产业数据库 / 公司数据库 / 数据底表 / 指标库 / 数据库搭建”
---

# SM Industry Database

这个 skill 用来搭建“能长期维护、能追溯来源、能直接继续分析”的数据库底表，而不是一次性摘数字。

## 强制流程（v0.9.2 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 6 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 8 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检

Industry Database 特别注意：

- **主交付必须是 `.xlsx`**，不能只交 `.md`
- **同时必须写一份同名 `.md` 说明文件**，用于归档说明、字段字典、缺口清单和刷新建议
- **每一条数据都要有完整中文证据等级 + 具体来源**
- **卖方报告可以入库，但必须单独标注来源类型，且不能伪装成公司公开披露**

## 适用场景

- “帮我搭一个光模块行业数据库”
- “把 AI 眼镜产业链做成数据库”
- “给这家公司搭一个长期更新的经营指标库”
- “把公开市场、卖方拆分和行业数据库里的核心指标整理到 Excel”

## 这类任务的默认交付

1. **一个 Excel 主文件**：结构化字段齐全，可继续维护
2. **一个 Markdown 归档说明**：说明这次库的范围、口径、来源和缺口
3. **一个刷新清单**：后续哪些字段按周 / 月 / 季更新

## Excel 结构（默认四张 sheet）

### 1. `README`

记录：

- 数据库名称
- 覆盖范围（行业库 / 公司库 / 指标库）
- 时间跨度
- 口径说明
- 本次使用的数据源链
- 最近刷新日期

### 2. `database`

这是主表，默认使用**长表结构**。每一行只表达一个数据点。

**必备列**：

| 列名 | 用途 |
|---|---|
| `record_id` | 唯一行号 |
| `database_type` | `industry` / `company` / `theme` |
| `entity` | 公司 / 子行业 / 区域 / 指标对象 |
| `indicator_group` | 收入 / 出货 / 价格 / 产能 / 份额 / 资本开支等 |
| `indicator_name` | 具体指标名 |
| `period` | 年 / 季 / 月 / 周 / 日期 |
| `frequency` | annual / quarterly / monthly / weekly / event |
| `value` | 数值 |
| `unit` | 台 / 片 / 美元 / 百分比等 |
| `currency` | CNY / USD / HKD / JPY / KRW / NA |
| `source_type` | 公司披露 / 行业数据库 / 卖方报告 / 公开市场 / 新闻 / 自行测算 |
| `source_name` | 数据库名 / 报告名 / 公告名 / 网站名 |
| `source_detail` | 页码 / 表名 / query / URL / 报告标题 |
| `source_date` | 源材料日期 |
| `captured_at` | 本次入库日期 |
| `evidence_label` | 公开事实 / 财报披露 / 市场共识 / 合理推演 / 待核验假设 |
| `public_reuse` | `yes` / `no`，是否适合未来外发复用 |
| `derivation_note` | 如果是估算或换算，写清公式或推导链 |
| `status` | confirmed / provisional / missing |
| `note` | 备注 |

### 3. `source_log`

按“源”而不是按“数据点”记一张来源日志，便于后续回看和刷新：

| 列名 | 用途 |
|---|---|
| `source_id` | 唯一来源编号 |
| `source_type` | 公司披露 / 行业数据库 / 卖方报告 / 公开网页等 |
| `source_name` | 来源名称 |
| `source_date` | 来源日期 |
| `coverage_scope` | 覆盖了哪些指标 |
| `usage_limit` | 可外发 / 仅内部 / 待核验 |
| `refresh_hint` | 下次应从哪里继续更新 |

### 4. `evidence_guide`

这张 sheet 专门把证据等级写成**完整中文**，不再使用字母缩写：

| 证据等级 | 说明 | 能否作为核心结论依据 |
|---|---|---|
| `公开事实` | 公开、稳定、可直接验证的事实 | 可以 |
| `财报披露` | 财报、公告、官方披露、权威数据库中的明确数字或事实 | 可以 |
| `市场共识` | 卖方一致预期、市场普遍看法、可验证的共识口径 | 只能辅助 |
| `合理推演` | 基于已知事实做出的推导或换算，必须写出链路 | 只能辅助 |
| `待核验假设` | 传闻、渠道、初步线索或尚未核验的判断 | 不能单独作结论 |

## 数据源使用纪律

### 优先级

1. 公司公告 / 年报 / 季报 / 业绩会
2. 权威行业数据库 / EDB / iFind EDB / 第三方产业数据库
3. 公开市场数据
4. 卖方报告
5. 自行测算

### 卖方报告的特殊规则

- 可以作为**内部数据库来源**
- 必须在 `source_type` 明确写 `卖方报告`
- 必须在 `public_reuse` 标 `no`，除非同一数据点已被公开披露复核
- 不得把卖方报告数据冒充成“财报披露”或“公开事实”

## 执行步骤

### 1. 先定义数据库边界

必须先明确：

- 是产业库还是公司库
- 最终要覆盖哪些指标
- 时间频率是年 / 季 / 月 / 周 / 事件
- 未来谁会继续更新这张表

没有边界就不要直接抓数。

### 2. 先出字段清单，再抓数

先列字段，不要一边搜一边乱填。

默认字段先按四层拆：

1. **对象层**：公司、子行业、区域、客户、产品
2. **经营层**：收入、出货、产能、份额、库存、订单
3. **市场层**：价格、估值、交易、市场预期
4. **来源层**：来源类型、日期、页码、证据等级、是否可外发

### 3. 抓数时先保留“原口径”

- 原始数字和换算数字不要混在一起
- 只要做了估算，就在 `derivation_note` 里写明公式
- 不要把月度值自动年化后覆盖原始值

### 4. 缺失值必须显式记录

数据库里允许存在 `missing`，但不允许“留空却不解释”。

拿不到的数据：

- `value` 留空
- `status` 写 `missing`
- `note` 写明建议来源或为什么当前拿不到

### 5. 最终交付要同时给“库”和“说明”

`.xlsx` 里放结构化数据；
`.md` 里必须写：

- 本次数据库范围
- 关键字段定义
- 已覆盖来源
- 仍需补的资料
- 刷新节奏建议

## 默认输出结构（对话 + 归档说明）

```markdown
# {数据库名称}

## 本次数据库范围
- ...

## 字段设计
- ...

## 已覆盖的数据源
- ...

## 关键发现
- ...

## 仍需补的资料
**必需**：
- ...

**建议**：
- ...

**不确定但影响判断**：
- ...

---

⚠️ 合规声明：本数据库用于研究辅助，不构成投资建议。
```

## 输出归档路径

### 公司数据库

```
{coverage_root}/{ticker}_{name}/database/{YYYY-MM-DD}-database.xlsx
{coverage_root}/{ticker}_{name}/database/{YYYY-MM-DD}-database.md
```

### 行业 / 主题数据库

```
{workspace_root}/themes/{theme-slug}/database/{YYYY-MM-DD}-database.xlsx
{workspace_root}/themes/{theme-slug}/database/{YYYY-MM-DD}-database.md
```

## 约束

- ❌ 不只交文字总结，不交 Excel
- ❌ 不把不同来源的数据直接混成一个“唯一正确答案”
- ❌ 不省略来源日期、页码、query、报告标题这些追溯字段
- ❌ 不再使用 `F1/F2/M1/C1/H1` 这类字母缩写
- ✅ 必须用完整中文证据等级
- ✅ 必须单独记录卖方报告和行业数据库来源
- ✅ 必须给出未来刷新建议

## 与其他 skill 的关系

| 关系 | 说明 |
|---|---|
| **上游** | 可先用 `sm-industry-map` 定义产业链框架 |
| **平行** | `sm-company-deepdive` 负责写研究，`sm-industry-database` 负责搭长期底表 |
| **下游** | 数据库可以继续供 `sm-thesis` / `sm-consensus-watch` / `sm-pm-brief` 调用 |

## 参考

- [../../core/adapters.md](../../core/adapters.md)
- [../../core/evidence.md](../../core/evidence.md)
- [../../core/output-archive.md](../../core/output-archive.md)
- [../../core/acceptance.md](../../core/acceptance.md)
