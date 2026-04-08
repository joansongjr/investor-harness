# User Templates · L1 用户自定义任务模板

> v0.7 新增。让用户把**重复的格式化任务**（日报 / 周报 / 月报 / 财报季流程）固化成文件，永久复用。
>
> 这是"任务永久化"三层的**第一层 L1**：模板层（复用 sm-* skill，自定义输出结构和归档路径）。

---

## 核心思想

用户的"我的日报"不是 LLM 的对话记忆，也不是散落的 Google Doc，而是一个**工作区里的 markdown 文件**。任何新会话、任何 agent、任何时间都能读到它、按它执行、归档到规定位置。

**一句话**：**把重复任务变成可读、可改、可版本化的文件**。

---

## 文件位置

```
{workspace_root}/
├── user-templates/
│   ├── daily-briefing.md         ← 日报模板
│   ├── weekly-coverage-review.md ← 周度覆盖池复盘
│   ├── monthly-pm-report.md      ← 月度 PM 汇报
│   └── earnings-calendar.md      ← 财报日历追踪
```

---

## 模板文件格式

每个用户模板是一个 markdown 文件，**必须**包含以下 frontmatter 字段：

```markdown
---
name: 我的晨会日报
trigger:                         # 自动路由触发词（可多个）
  - "跑一下日报"
  - "生成今天的晨会"
  - "每日简报"
frequency: daily                 # 频率（daily / weekly / monthly / event-driven）
based_on_skill: sm-briefing      # 基于哪个 sm-* skill（必填）
output_to: "briefings/{YYYY-MM-DD}-morning.md"   # 归档路径（支持变量）
market: CN-A                     # 主要市场（可选，决定数据源优先级）
coverage_scope: all              # all / watchlist / specific（可选）
---

# 模板名称

## 模板说明
（用户写的描述，LLM 会读但不会要求）

## 输入（用户说"跑一下日报"时，LLM 自动获取的信息）
- 自动从 coverage.md 拿覆盖池
- 自动从 news MCP 拉近 12 小时资讯
- 可选输入：特定板块 / 重点关注标的

## 输出结构（用户自定义，**会覆盖 based_on_skill 的默认结构**）

### 1. 开盘前 3 件事
（具体到 3 件，不多不少）

### 2. 覆盖池异动
只列涨跌幅 > 3% 的标的

### 3. 今日关键财报 / 会议
按时间排序

### 4. 待我决策的事项
给 PM 看的 action items

### 5. 一句话给自己
复盘 / 提醒

## 约束（用户自定义的硬约束）
- 长度不超过 500 字
- 不要写"宏观波动"这种套话
- 所有数据必须带 F1/F2 证据等级
- 输出完成后更新 coverage.md 最后扫描时间
```

---

## 触发机制（双路径）

v0.7 支持**自动路由 + 显式调用**两种触发方式。

### 方式 A：自动路由（优先）

用户说"跑一下日报"，LLM 按以下顺序匹配：

1. 读 `{workspace}/user-templates/*.md` 的 frontmatter
2. 提取所有 `trigger:` 数组
3. 和用户输入做模糊匹配（全词匹配优先，子串匹配其次）
4. 命中一条 → 用该模板
5. 命中多条 → 列出来让用户选
6. 零命中 → 走默认 sm-* skill 路由

### 方式 B：显式调用

用户说"用我的日报模板" / "跑我的 daily-briefing 模板"：

1. 按名字（frontmatter `name:` 或文件名）精确查找
2. 直接加载对应模板

---

## LLM 执行用户模板的完整流程

### Step 1 · 识别是模板任务

在 preamble.md Step 1 之后、Step 2 之前，LLM 额外做一步：

```
检查 {workspace}/user-templates/ 是否有匹配的模板
→ 有：加载模板，记下 based_on_skill 和 output_to
→ 无：走常规 sm-* skill 路由
```

### Step 2 · 加载父 skill

如果模板指定了 `based_on_skill: sm-briefing`，LLM 加载 `sm-briefing/SKILL.md` 作为**执行框架**。

但**输出结构用用户模板的，不用父 skill 的**。

### Step 3 · 走完整 preamble（6 步）

和普通 skill 一样走取数、证据分级、检查历史等。

### Step 4 · 按用户模板的 5 段（或 N 段）输出

严格按用户 `## 输出结构` 段的定义。如果用户写了"5 段"而不是 sm-briefing 默认的 5 段，听用户的。

### Step 5 · 归档到 `output_to` 路径

用户模板的 `output_to` **覆盖** `core/output-archive.md` 的默认路径。例如：
- `output_to: "briefings/{YYYY-MM-DD}-morning.md"`
- 默认：`coverage/{ticker}/briefing/{YYYY-MM-DD}.md`
- 模板优先 → 归档到 `briefings/{YYYY-MM-DD}-morning.md`

支持变量：
- `{YYYY-MM-DD}` — 当天日期
- `{YYYY-MM}` — 当月
- `{YYYY}` — 年份
- `{WEEK}` — 周数（ISO week）
- `{TICKER}` — 标的代码（单标的任务时）
- `{WORKSPACE_ROOT}` — 工作区根目录

### Step 6 · 仍然走完整 postamble

证据自检 / 验收清单 / Dual Output 一样都不能少。用户模板**继承**合规边界，不能绕过。

---

## 定时任务集成（scheduled-tasks）

如果用户想"每天 9 点自动跑日报"，配合 Claude Code 的 `scheduled-tasks` MCP：

```
/schedule "每个工作日上午 9:00，跑我的日报模板"
```

`scheduled-tasks` 会在指定时间给 LLM 发条消息"跑一下日报"，LLM 按本文件的自动路由流程执行。

**永久化的威力**：
- 你的日报每天 9 点自动跑
- 归档到 `briefings/2026-04-08-morning.md`
- LLM 看完即忘，但文件永久存在
- 你任何时候打开工作区都能看到历史日报

---

## 例子：最常见的 3 个模板

Investor Harness 自带 3 个**示例模板**在 `setup/workspace/user-templates/`：

1. `daily-briefing.md.template` — 每日晨会日报
2. `weekly-coverage-review.md.template` — 周度覆盖池复盘
3. `monthly-pm-report.md.template` — 月度 PM 汇报

`bootstrap.sh` 会把这些模板复制到用户工作区作为起点，用户改成自己的。

---

## 写好用户模板的原则

### ✅ 好的模板

- `trigger:` 列 2-4 个具体触发词
- `based_on_skill:` 明确指定一个 sm-* skill（不能空）
- `output_to:` 路径清晰，用变量避免重名
- `输出结构` 写具体到段（不要"大概包括几段"这种模糊）
- `约束` 写硬约束（长度 / 禁用词 / 必填项）

### ❌ 不好的模板

- `trigger:` 写成"各种投研任务"（太泛）
- `based_on_skill:` 留空或写"autopilot"（autopilot 本身是路由器，不是执行器）
- `output_to:` 不带日期变量 → 每次覆盖同一个文件
- `输出结构` 抄 sm-briefing 原文（那还不如直接用 sm-briefing）
- 试图在模板里绕过合规 / 证据分级（core/ 的硬约束不能 override）

---

## 与 L2 用户 skills 的区别

| 维度 | L1 User Templates | L2 User Skills（见 user-skills.md） |
|---|---|---|
| 文件位置 | `user-templates/*.md` | `user-skills/{name}/SKILL.md` |
| 是否新 skill | 否（复用 sm-*）| 是（继承或全新）|
| 改变什么 | 输出结构 + 归档路径 | 完整的分析框架 |
| 适合场景 | 日报 / 周报 / 月报 | 新分析方法 / ESG 专项 / 港股打新 |
| 复杂度 | 低（10 分钟写完）| 中-高（需要懂 skill 结构）|

**选择原则**：能用 L1 解决的，不要用 L2。能用 sm-* 默认的，不要用 L1。

---

## 硬约束（用户模板不能绕过）

无论模板怎么写，以下规则**不能被覆盖**：

- ❌ 不能绕过 `core/preamble.md` 的 6 步开始前流程
- ❌ 不能绕过 `core/postamble.md` 的 8 步结束后流程
- ❌ 不能绕过证据等级标注
- ❌ 不能绕过"仍需补的资料"段
- ❌ 不能绕过合规声明
- ❌ 不能跳过 Dual Output Discipline（对话 + 文件双输出）

**用户模板只能自定义**：
- ✅ 输出段的具体结构（几段、叫什么名字、重点是什么）
- ✅ 归档路径
- ✅ 触发词
- ✅ 输入范围（coverage 全部 vs 子集）
- ✅ 额外的硬约束（字数上限、禁用词）

---

## LLM 遇到用户模板时的行为自检

LLM 必须能回答以下问题才算正确执行了用户模板：

- [ ] 我读过 user-templates/ 目录吗？
- [ ] 我匹配到了哪个模板？（告知用户）
- [ ] 我知道 based_on_skill 是哪个吗？
- [ ] 我按用户的输出结构，而不是父 skill 默认结构吗？
- [ ] 我归档到了 output_to 指定的路径吗？
- [ ] 我仍然走了完整的 preamble / postamble 吗？
- [ ] 我的输出包含证据等级、仍需补、合规声明吗？

任何一项答不出 → 未正确执行 → 重来。
