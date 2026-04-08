---
name: sm-deck-builder
description: 二级市场投研 PPT 生成 skill。把已有的研究输出（sm-company-deepdive / sm-thesis / sm-red-team / sm-earnings-preview 等）转成**机构级投研路演 PPT**，带完整 UI 设计系统、10 段标准结构、证据可追溯标注。适合 IC 会议、路演、PM 汇报、客户展示。依赖 anthropic-skills:pptx 做实际文件生成。
inputs:
  - 公司名 / 股票代码 / 行业 / 主题
  - 可选：已有研究材料、命题、反方审视、财报前瞻
  - 可选：deck 类型（IC / roadshow / earnings / monthly）
  - 可选：长度（5 / 10 / 20 slides）
  - 可选：品牌色 / logo
outputs:
  - .pptx 文件 + 内容摘要
  - 归档到 {coverage}/{ticker}/decks/{YYYY-MM-DD}-{deck-type}.pptx
data_sources:
  - 优先：{coverage_root}/{ticker}/ 下的历史研究（thesis / deepdive / red-team / earnings）
  - 备选：见 ../../core/adapters.md
markets: [CN-A, HK, US, GLOBAL]
---

# SM Deck Builder

> **Investor Harness 第 18 个 skill**。把你散落在 markdown 里的研究输出，变成 PM / IC / 客户能看懂的**专业投研 PPT**。
>
> 不做花哨的动画、不做 hero banner、不做 emoji 狂欢。只做一件事：**让你的研究在 10 页纸里站得住**。

## 强制流程（v0.4+ 硬约束）

> ⛔ **任何 deck 生成之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 6 步开始前流程
>
> ⛔ **任何 deck 完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 8 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检
>
> **跳过任何一环视为未完成任务。**

Deck Builder 特别注意：
- **preamble Step 2 必须读取** 同标的最新的 `sm-company-deepdive` / `sm-thesis` / `sm-red-team` / `sm-earnings-preview` / `sm-consensus-watch` 的归档输出。没有这些研究底稿，**禁止**直接生成 deck。
- 如果用户没跑过任何研究，先提醒他："deck 是研究的包装，不是替代。建议先跑 sm-company-deepdive + sm-thesis 再来"。
- 所有 PPT 内的事实**必须**带证据等级标注（以脚注或角标形式），和主研究保持一致。

---

## 适用场景

| 场景 | Deck 类型 | 长度 |
|---|---|---|
| IC 投委会 | `ic-pitch` | 10-15 页 |
| 管理层路演 | `roadshow` | 5-8 页 |
| 财报复盘 | `earnings-review` | 6-10 页 |
| 月度 PM 汇报 | `monthly-update` | 5 页 |
| 客户展示 | `client-pitch` | 10-20 页 |
| 内部研究分享 | `research-share` | 10-15 页 |

## 不适用

- ❌ 完全没有研究底稿的情况下生成 deck（这会变成营销物料不是研究）
- ❌ 营销 / 销售宣传 PPT
- ❌ 路演发行承销商角度的 IPO 招股 PPT
- ❌ 需要实时动画 / 视频嵌入的场景（这个 skill 只出静态结构化 deck）

---

## 必答问题（生成 deck 前必须回答）

1. Deck 类型是什么？给谁看？
2. 目标长度（页数）？
3. 有没有已有的研究底稿？存放位置？
4. 核心投资命题是什么（一句话）？
5. 想不想带合规声明 / 免责页？
6. 有没有品牌色 / logo 要求？
7. 输出文件名和归档位置？

---

## 输出结构（标准 10 页 IC Pitch Deck）

### Slide 1 · 封面 (Cover)

```
[Logo 占位]

{Company Name} ({Ticker})
{Sector} · {Market}

Investment Thesis Pitch

Analyst: {Name}
Date: {YYYY-MM-DD}
Confidence: High / Medium / Low

—— INTERNAL USE ONLY · NOT INVESTMENT ADVICE ——
```

### Slide 2 · 执行摘要 (Executive Summary)

一张 slide 讲清楚整个故事：

```
Investment Thesis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{一句话命题 — 不超过 25 字}

Three Supporting Pillars
  1. {Pillar 1 — 一句话}
  2. {Pillar 2 — 一句话}
  3. {Pillar 3 — 一句话}

Recommended Action
  {BUY / HOLD / SELL / WATCH}
  {仓位建议 + 时间窗}

⚠️ 需人工复核
```

### Slide 3 · 公司概览 (Company Overview)

```
┌────────────────────────────────────────┐
│ Business Model                         │
│ {3-5 句话业务描述}                      │
├────────────────────────────────────────┤
│ Key Metrics (FY{N-1})                  │
│  Revenue:    {XX} 亿 (F2)              │
│  Net Profit: {XX} 亿 (F2)              │
│  Margin:     {XX}%    (F2)             │
│  Market Cap: {XX} 亿 (F1)              │
├────────────────────────────────────────┤
│ Positioning                            │
│ {在产业链 / 行业中的位置}                │
└────────────────────────────────────────┘
```

### Slide 4 · 核心逻辑 (The Thesis)

```
Core Thesis
{一句话}

Why Now?
{为什么是现在，不是 3 个月前，也不是 3 个月后}

The Variant View
Market Consensus      Your View           Gap
─────────────────     ────────────        ────
{市场怎么想}           {你怎么想}           {分歧在哪}
```

### Slide 5 · 支撑证据 (Evidence)

一页放 3-5 个最硬的数据点，每个**必须**带证据等级：

```
Evidence 1: {要点}
  Data:   {数据}
  Source: F2 (公司 2024 年报)
  Why it matters: {一句话解读}

Evidence 2: ...
Evidence 3: ...

[图表占位符：收入增速 / 毛利率趋势 / 份额变化]
```

### Slide 6 · 市场预期差 (Consensus Gap)

```
Market Has Priced In              Market Has NOT Priced In
────────────────────              ────────────────────────
✓ {已 price in 1}                 ? {未被充分反映的变量 1}
✓ {已 price in 2}                 ? {未被充分反映的变量 2}
✓ {已 price in 3}                 ? {未被充分反映的变量 3}

Conditions for Re-rating
  1. {触发条件 1}
  2. {触发条件 2}
  3. {触发条件 3}
```

### Slide 7 · 催化剂 (Catalysts)

时间线形式：

```
Timeline of Catalysts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{now}──────{Q+1}──────{Q+2}──────{Q+3}──────{Q+4}
  │           │           │           │           │
  ↓           ↓           ↓           ↓           ↓
 {事件 1}    {事件 2}    {事件 3}    {事件 4}    {事件 5}

Top Catalysts to Watch
  🔥 {最重要的催化剂}
  ⚡ {次要催化剂}
```

### Slide 8 · 反方审视 (Red Team)

**这页绝对不能省**。机构 PM 最看重的就是你能不能 red team 自己。

```
Top 3 Risks (Observable, Actionable)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Risk 1: {可观测的风险}
  Trigger: {什么数据出现就该 cut loss}

Risk 2: {可观测的风险}
  Trigger: {...}

Risk 3: {可观测的风险}
  Trigger: {...}

Kill Switch
If ANY two of the above trigger → 立即 re-evaluate 命题
```

### Slide 9 · 跟踪指标 (What to Watch)

```
Next 3 Months · Track List
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Metric 1: {跟踪指标}
  Frequency: {每月 / 每季 / 事件}
  Source: {在哪看}
  Target: {多少算 on-track}

Metric 2: ...
Metric 3: ...

[Mini 仪表盘占位符：3 个 KPI 的 traffic light 状态]
```

### Slide 10 · 附录 & 合规 (Appendix)

```
Sources Used (F1/F2/M1/C1/H1 Breakdown)
  F1 公开事实:     {N} 条
  F2 财报公告:     {N} 条
  M1 市场观点:     {N} 条
  C1 基于事实推演: {N} 条
  H1 待核验线索:   {N} 条

仍需补的资料 (Gaps)
  必需: {list}
  建议: {list}

免责声明 / Disclaimer
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
本 deck 仅用于内部研究讨论，不构成投资建议。所有
数据来自公开渠道。涉及评级 / 目标价 / 盈利预测调
整须经持牌分析师人工复核。投资有风险，入市需谨慎。

Analyst: {Name}  Date: {YYYY-MM-DD}  Version: {v}
Sources archived at: {coverage}/{ticker}/
```

---

## UI 设计系统（Machine-Readable）

### 颜色方案

```yaml
theme: investor-harness-default
palette:
  primary:       "#1a2332"   # 深海军蓝（主色，标题、页眉、封面背景）
  accent:        "#c9a35c"   # 金色（强调色，用于关键数字、引用标注）
  positive:      "#2d7a3e"   # 深绿（用于"上涨/利好/共振"）
  negative:      "#a83232"   # 深红（用于"下跌/利空/风险"）
  neutral_dark:  "#4a5568"   # 深灰（body text）
  neutral_mid:   "#a0aec0"   # 中灰（副标题、脚注）
  neutral_light: "#edf2f7"   # 浅灰（分隔线、背景）
  white:         "#ffffff"   # 白（body 背景）
```

**色彩纪律**：
- ✅ 每张 slide 只有 **1 个** 主色 + **1 个** 强调色
- ✅ 涨用 `positive`，跌用 `negative`，不要反过来
- ❌ 不要用红绿对比做装饰（留给真正的涨跌数据）
- ❌ 不要用 > 3 种色相

### 字体系统

```yaml
typography:
  title:
    font: "PingFang SC / Helvetica Neue / Arial"  # 中英回退
    size: 32pt
    weight: Bold
    color: primary

  subtitle:
    font: "PingFang SC / Helvetica Neue / Arial"
    size: 18pt
    weight: Regular
    color: neutral_dark

  body:
    font: "PingFang SC / Helvetica Neue / Arial"
    size: 14pt
    weight: Regular
    color: neutral_dark

  caption:
    font: "PingFang SC / Helvetica Neue / Arial"
    size: 10pt
    weight: Regular
    color: neutral_mid

  evidence_tag:  # F1/F2/M1/C1/H1 标签
    font: "Menlo / Courier"
    size: 9pt
    weight: Medium
    color: accent
```

**排版纪律**：
- 每页 **一个** H1，不超过 1 行
- 每段正文不超过 5 行
- 数字用等宽字体对齐
- 证据等级标注用 `[F2]` 上标形式

### 布局网格

```
┌──────────────────────────────────────────────────┐
│ {Ticker + Deck Type}          {Analyst · Date}  │  ← Header (60px)
├──────────────────────────────────────────────────┤
│                                                   │
│  H1 Title                                        │  ← Title area (120px)
│  Subtitle                                        │
│                                                   │
│ ┌────────────────────────────────────────────┐  │
│ │                                             │  │
│ │           Content area                      │  │  ← Body (480px)
│ │           (16:9, 1920×1080)                 │  │
│ │                                             │  │
│ └────────────────────────────────────────────┘  │
│                                                   │
├──────────────────────────────────────────────────┤
│ {Logo}     {Page N / M}     NOT INVESTMENT ADV.  │  ← Footer (60px)
└──────────────────────────────────────────────────┘
```

**留白纪律**：
- 上下边距 60px
- 左右边距 80px
- 内容密度：**宁空勿满**

### 图表风格

- ✅ 简洁线图 / 柱图 / 堆叠柱
- ✅ 坐标轴单位清晰（亿元 / %）
- ✅ Y 轴不从零开始时必须标注
- ✅ 图表下方带数据来源标签 (F1/F2...)
- ❌ 不要用 3D 饼图 / 3D 柱状图
- ❌ 不要用彩虹色
- ❌ 不要用默认 Excel 风格

---

## 技术实现

### 依赖

- **主依赖**：`anthropic-skills:pptx` skill（python-pptx 包装）
- **可选**：`matplotlib` / `plotly`（如需生成图表图片）

### 执行流程

```
1. Preamble (6 steps)
   ↓
2. 读取工作区 {coverage_root}/{ticker}/
   - latest thesis
   - latest deepdive
   - latest red-team
   - latest earnings (if exists)
   - latest consensus-watch (if exists)
   ↓
3. 提炼 10 slides 所需的结构化内容
   ↓
4. 调用 anthropic-skills:pptx skill 生成 .pptx
   - 传入 UI 设计系统（颜色 / 字体 / 布局）
   - 传入 10 slides 的内容 dict
   ↓
5. 保存文件到归档路径:
   {coverage}/{ticker}/decks/{YYYY-MM-DD}-{deck-type}.pptx
   ↓
6. 同时输出 markdown 版本（方便对话里预览）:
   {coverage}/{ticker}/decks/{YYYY-MM-DD}-{deck-type}.md
   ↓
7. Postamble (8 steps)
   ↓
8. Dual Output Discipline:
   - 对话贴 markdown 预览（每页标题 + 核心内容）
   - 文件写 .pptx 真正的 PowerPoint
   - 末尾追加 📁 已归档提示 + 关键统计
```

### 输入与输出的数据契约

**输入结构**（preamble Step 2 读完研究后应生成这个）：

```yaml
deck_spec:
  target: "{ticker}_{name}"
  market: CN-A | HK | US | ...
  deck_type: ic-pitch | roadshow | earnings-review | monthly-update | ...
  length: 10
  analyst: "{name}"
  date: "{YYYY-MM-DD}"

  inherited_research:
    thesis:
      path: "{coverage}/{ticker}/thesis/latest.md"
      one_liner: "..."
      pillars: ["...", "...", "..."]
    deepdive:
      path: "{coverage}/{ticker}/deepdive/latest.md"
      company_overview: {...}
      business_model: "..."
      key_metrics: {revenue, profit, margin, market_cap}
    red_team:
      path: "{coverage}/{ticker}/red-team/latest.md"
      risks: ["...", "...", "..."]
      kill_switch_triggers: ["...", "...", "..."]
    earnings:
      path: "{coverage}/{ticker}/earnings/latest.md"
      next_date: "{YYYY-MM-DD}"
      sensitive_vars: [...]
    consensus_watch:
      path: "{coverage}/{ticker}/consensus/latest.md"
      priced_in: [...]
      not_priced_in: [...]

  slide_content:
    - id: 1
      type: cover
      content: {...}
    - id: 2
      type: executive-summary
      content: {...}
    # ... 10 slides total

  ui:
    theme: investor-harness-default
    brand_logo: null  # 用户可上传
    brand_color_override: null
```

**输出结构**（postamble Step 4/7）：

```
Files created:
  📊 {coverage}/{ticker}/decks/{YYYY-MM-DD}-{deck-type}.pptx    ← 真正的 PPT
  📝 {coverage}/{ticker}/decks/{YYYY-MM-DD}-{deck-type}.md     ← markdown 预览

Preview in chat (dual output):
  [每页的标题 + 核心要点，markdown 版]
```

---

## 约束（硬约束）

### 内容纪律
- ❌ **严禁**在没有研究底稿的情况下直接生成 deck
- ❌ **严禁**编造数据 — 所有数字必须来自归档的研究输出
- ❌ **严禁**省略 "Risk / Red Team" 页
- ❌ **严禁**省略 "仍需补的资料 / Gaps" 页
- ❌ **严禁**在每张 slide 上堆超过 5 个 bullet points
- ❌ **严禁**使用"必涨"、"看到 XX 元"等武断表述
- ✅ 每个具体数字必须标证据等级
- ✅ 每份 deck 必须带合规免责页

### 视觉纪律
- ❌ 不要动画、转场效果
- ❌ 不要 clipart / stock photo 塞满
- ❌ 不要 emoji 装饰（✓ 标记可以）
- ❌ 不要 3D 图表
- ❌ 不要超过 3 种字体
- ❌ 不要超过 3 种颜色（primary + accent + 1 个 semantic）
- ✅ 留白 ≥ 30%
- ✅ 每页一个核心信息
- ✅ 数据图表 > 文字描述

### 长度纪律
- ic-pitch: **10-15 页**，默认 10
- roadshow: **5-8 页**，默认 6
- earnings-review: **6-10 页**，默认 8
- monthly-update: **5 页**（一页纸精神）
- 超过上限 → 让用户分两次跑，不要堆

---

## 触发方式

- "帮我生成 {X} 的 IC pitch deck"
- "把 {X} 的研究做成 PPT"
- "给 PM 做一份 {X} 的路演 deck"
- "用 sm-deck-builder 生成 {X} 的汇报材料"
- "{X} 做成 5 页月报 deck"
- "把今天的 deepdive 转成 PPT"

---

## 归档路径

```
{coverage_root}/{ticker}_{name}/decks/
├── 2026-04-07-ic-pitch.pptx
├── 2026-04-07-ic-pitch.md           ← markdown 预览
├── 2026-04-15-roadshow.pptx
├── 2026-04-15-roadshow.md
└── 2026-05-01-earnings-review.pptx
```

**文件命名规范**：`{YYYY-MM-DD}-{deck-type}.pptx`

---

## 与其他 skill 的关系

| 关系 | skill | 说明 |
|---|---|---|
| **强依赖** | `sm-company-deepdive` | 必须至少读到一份 deepdive 才能做 ic-pitch |
| **强依赖** | `sm-thesis` | 命题来源 |
| **强依赖** | `sm-red-team` | Slide 8 内容必须来自这里 |
| **强依赖** | `sm-earnings-preview` | earnings-review deck 的数据源 |
| **补充** | `sm-consensus-watch` | Slide 6 的预期差来源 |
| **补充** | `sm-catalyst-monitor` | Slide 7 的催化剂时间线 |
| **互补** | `sm-pm-brief` | pm-brief 是一页纸文字，deck-builder 是 10 页 PPT |
| **不替代** | `anthropic-skills:pptx` | deck-builder 调用 pptx 做文件生成，但决定结构/UI/内容的是 deck-builder |

**推荐流程**：
```
sm-thesis → sm-company-deepdive → sm-red-team → sm-consensus-watch
                                                          ↓
                                                sm-deck-builder
                                                          ↓
                                                     IC pitch PPT
```

## Dual Output Discipline

对话里输出：
1. Deck 的 10 slides markdown 大纲（完整内容，方便云端用户阅读）
2. 归档路径 + 文件大小
3. 使用的 UI 主题
4. 继承自哪些研究底稿（带日期 + 证据等级统计）

文件里保存：
1. `.pptx` 真正的 PowerPoint 文件（用 anthropic-skills:pptx 生成）
2. `.md` markdown 版本（和对话里一致，方便 diff 和跨 skill 引用）

## 参考

- [../../core/preamble.md](../../core/preamble.md)
- [../../core/postamble.md](../../core/postamble.md)
- [../../core/evidence.md](../../core/evidence.md)
- [../../core/compliance.md](../../core/compliance.md)
- [../../core/output-archive.md](../../core/output-archive.md)
- [../../core/acceptance.md](../../core/acceptance.md)
- `anthropic-skills:pptx` — 实际生成 .pptx 文件的底层 skill
