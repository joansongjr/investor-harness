# Preamble · 强制开始前流程

> 所有 sm-* skill 在产生任何分析输出**之前**，必须按本文件依序完成 5 个步骤。
> 这是治"幻觉"和"健忘"的核心机制——跳过任何一步视为未完成任务。

---

## Step 1 · 识别市场

按 [markets.md](markets.md) 确定标的的市场归属：

- `CN-A` — A 股 / 沪深
- `CN-FUND` — 公募基金
- `HK` — 港股
- `US` — 美股
- `GLOBAL` — 跨市场主题 / 行业

输出标记：`市场：{CN-A | CN-FUND | HK | US | GLOBAL}`

---

## Step 2 · 检查历史输出（治健忘）

按 [output-archive.md](output-archive.md) 的归档路径检查：

```
{coverage_root}/{ticker}/research/
{coverage_root}/{ticker}/{skill}/
```

**如果存在同标的、同 skill 的历史输出**：
- 读取最近一次输出
- 在本次输出开头声明：`本次为更新（上次：YYYY-MM-DD）`
- 重点输出"自上次以来的变化"，避免完全重写

**如果存在同标的、其他 skill 的历史输出**：
- 引用其结论作为本次工作的输入（标 M1 或 C1）
- 例：`命题来自 sm-thesis 输出 (2026-02-15)`

**如果完全无历史**：
- 在本次输出开头声明：`本次为首次研究`
- 进入下一步

---

## Step 3 · 检查任务进度（治健忘）

读取 `{workspace_root}/active-tasks.md`：

- 是否存在与本次任务相关的"进行中"任务？
- 如果是 → 读取 `progress` 字段，从断点继续
- 如果否 → 在本次工作开始时创建一条新的 active task

任务状态记录格式见 [`../setup/workspace/active-tasks.md.template`](../setup/workspace/active-tasks.md.template)。

---

## Step 4 · 输出 [Preflight] 取数计划（治幻觉）

按 [adapters.md](adapters.md) 的数据源决策树，**强制**输出以下结构：

```
[Preflight]
标的：{公司/行业/主题}
市场：{Step 1 的结果}
历史状态：{Step 2 的结果，"首次研究" 或 "更新（上次 YYYY-MM-DD）"}
任务进度：{Step 3 的结果，"新任务" 或 "续 task-id"}

数据源优先级链：
  1. {工具 A} → {预期拉取什么}
  2. {工具 B} → {备用 / 补充}
  3. {工具 C} → {兜底}

预期缺失项：
  - {可能拿不到的关键数据 1}
  - {可能拿不到的关键数据 2}
  → 这些将在末尾"仍需补的资料"段明确列出
```

**⛔ 严禁跳过 Preflight 直接开始分析输出。**

如果用户没给标的代码或者市场不明确：
- 先问一句歧义澄清问题（仅限同名标的、市场不明这两种情况）
- 拿到答案后再走完 Preflight

---

## Step 5 · 按优先级实际取数

按 Preflight 写的优先级链，**实际调用工具拿数据**：

- **不要**只在 Preflight 里"声称"要拿什么，要真去拿
- 拿到的每条数据**立即**标证据等级（F1/F2/M1/C1/H1，见 [evidence.md](evidence.md)）
- 拿不到的数据**立即**记录到"缺失项实际清单"，等会写进 postamble 的"仍需补的资料"段

---

## 完成 Preamble 之后

进入对应 skill 的具体分析流程。

分析输出的结尾必须按 [postamble.md](postamble.md) 走强制结束流程。

---

## 例外说明

**仅以下情况允许跳过 Preamble**：

- 用户明确说"不需要取数，我直接贴材料"——此时 Step 4 的优先级链直接写"用户提供材料"
- 用户明确说"快速看一下，不用深度"——此时仍需 Step 1/2/3，但 Step 4 可以简化

**任何其他情况跳过 Preamble 都视为违规。**
