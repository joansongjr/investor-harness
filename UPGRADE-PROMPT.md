# Investor Harness · 保守升级提示词（v0.9.9）

> 给**已经安装过 investor-harness** 的用户使用。  
> 目标不是重装，而是把本地框架**升级到新版本**，同时**保留用户原有的个性化配置、工作区、研究归档、进行中任务和底稿**。

---

## 用户只需对 agent 说的一句话

> **"读 `~/investor-harness/UPGRADE-PROMPT.md`，然后帮我把本地 investor-harness 保守升级到 v0.9.9，保留我的个性化设置和任务底稿。"**

如果用户的安装路径不是 `~/investor-harness`，把上面的路径替换成自己的实际安装路径即可。

---

## 给 LLM / Agent 的执行指令

你现在执行的是 **Investor Harness 保守升级**，不是首次安装，也不是重装。

### 总目标

只同步上游 `v0.9.9` 的**框架变更**，并且保留用户已有的：

- 入口文件中 marker 外的个性化内容
- 工作区骨架和研究资产
- `user-templates/` 和 `user-skills/`
- `.task-pulse` / `.checkpoint/` / `active-tasks.md`
- 历史归档、研究底稿、进行中任务、覆盖池资料

---

## Step 0 · 先识别路径和版本

在修改任何文件之前，先识别：

1. **本地 investor-harness 安装路径**
   - 优先检查用户明确给的路径
   - 否则按顺序尝试：
     - `~/investor-harness`
     - `~/.codex/skills/investor-harness`
     - `~/.claude/skills/investor-harness`
     - 工作区内可能的 vendored 副本

2. **用户实际在用的投研工作区路径**
   - 如果当前目录明显是工作区，则优先用当前目录
   - 如不明确，检查是否存在 `coverage/`、`themes/`、`briefings/`、`.task-pulse`、`active-tasks.md`

3. **当前本地版本**
   - 优先从以下文件判断：
     - `README.md`
     - `ONBOARDING.md`
     - `setup/routes-block.template.md`
     - 入口文件里的 marker 版本

4. **目标版本**
   - 如果仓库存在显式 `v0.9.9` tag，则以 tag 为准
   - 如果没有显式 tag，则以 `README.md` / `ONBOARDING.md` / marker 中显示为 `v0.9.8` 的最新仓库状态为准

---

## Step 1 · 升级前审计（必须先报告）

在真正改任何文件之前，先给用户一份**升级审计**，至少包括：

1. 当前本地版本
2. 目标版本
3. investor-harness 安装目录是不是 git 仓库
4. 本地是否有未提交改动
5. 这次预计会更新哪些文件
6. 哪些文件/目录会明确保留
7. 哪些地方可能冲突，需要用户确认

如果这一步做不清楚，先停下来，不要直接覆盖文件。

---

## Step 2 · 这是升级，不是重装

默认原则：

- ✅ 优先**增量更新**
- ✅ 优先保留本地个性化内容
- ✅ 优先只更新框架层
- ❌ 不要删除后重下
- ❌ 不要重建整个工作区
- ❌ 不要因为升级而清空任务状态

### 情况 A：本地 harness 目录本身是 git 仓库

优先使用 git 升级：

1. `git fetch`
2. 对比本地与目标版本差异
3. 检查本地未提交改动
4. 如可安全升级，再 `git pull` / rebase / merge

硬约束：

- ❌ 不要 `git reset --hard`
- ❌ 不要直接覆盖本地改动
- 如果有本地改动，先保留，再尝试合并
- 如果无法安全自动合并，列出冲突文件给用户确认

### 情况 B：本地不是标准 git 仓库，或已被手工改乱

处理方式：

1. 临时 clone 一份上游 `v0.9.8` 到临时目录
2. 对比：
   - 当前本地安装
   - 上游临时副本
3. **只同步真正变化的框架文件**
4. 不要整目录粗暴覆盖

---

## Step 3 · 这些内容默认禁止覆盖

以下内容视为**用户资产**，除非用户明确点名允许，否则禁止覆盖、禁止删除、禁止重建。

### A. 工作区与研究资产

- `coverage/`
- `themes/`
- `briefings/`
- `.checkpoint/`
- `.task-pulse`
- `active-tasks.md`
- `memory.md`
- `coverage.md`
- `watchlist.md`
- `people-watch.md`
- `decision-log.md`
- `research-queue.md`
- `biases.md`
- `.supervision/`
- 所有历史研究归档、草稿、会议纪要、模型底稿、输出文件
- 所有 `coverage/{ticker}_{name}/...` 下已有内容

### B. 用户个性化扩展

- `user-templates/`
- `user-skills/`
- 用户自己写的触发词、模板、继承 skill、自创 skill
- 工作区里的本地偏好或个性化说明

### C. 入口文件里的用户内容

对 `AGENTS.md` / `CLAUDE.md` / `agent.md`：

- **只允许替换 investor-harness marker 包住的那一段**
- marker 外的内容一律保留
- ❌ 不要重写整个文件
- ❌ 不要打乱用户已有结构

---

## Step 4 · 允许更新哪些内容

这次升级默认只更新以下**框架层**内容：

- `skills/`
- `core/`
- `setup/`
- `README.md`
- `ONBOARDING.md`
- `INSTALL-PROMPT.md`
- `UPGRADE-PROMPT.md`
- 其他明确属于 investor-harness 框架本身的文件

如果某个框架文件被用户本地手动改过：

1. 先做备份
2. 再做审慎合并
3. 如果冲突明显，先报告用户，不要强行覆盖

---

## Step 5 · onboarding / 路由块更新规则

如果本地已经启用了 investor-harness 路由：

1. 检查入口文件里的 marker 版本是否落后
2. 如需更新，**只替换 marker 之间的内容**
3. marker 外的用户内容不得改动
4. 如果需要“重新跑 onboarding”，先告诉用户会改哪些入口文件

---

## Step 6 · bootstrap 规则

- ❌ 不要默认重跑 `setup/bootstrap.sh`
- 只有当前工作区缺少**新版本必需的骨架文件**时，才允许补建
- 补建必须满足：
  - 先列出缺哪些文件 / 目录
  - 明确说明“只补缺，不覆盖”
  - 征得用户确认后再执行

---

## Step 7 · 备份规则

所有准备修改的文件，先做一份可回滚备份。

推荐方式：

- 放到 `.upgrade-backup/{timestamp}/`
- 或生成同目录 `.bak.{timestamp}` 文件

重点备份：

- 将被修改的框架文件
- 入口文件（`AGENTS.md` / `CLAUDE.md` / `agent.md`）
- 路由块相关文件

注意：

- 不要为了备份把整个巨大工作区完整复制一遍，除非确实必要

---

## Step 8 · 交付要求

升级完成后，向用户输出一份**升级总结**，至少包括：

1. 当前已升级到的版本判断依据
2. 实际更新了哪些文件
3. 明确保留了哪些用户文件 / 目录
4. 哪些地方做了 marker 替换
5. 哪些地方只补缺、没有覆盖
6. 是否发现冲突或人工待处理项
7. 以后再升级建议说什么一句话 prompt

---

## 禁止动作

- ❌ `git reset --hard`
- ❌ 删除后重装整个工作区
- ❌ 覆盖 `user-templates/`、`user-skills/`
- ❌ 清空 `.task-pulse`、`.checkpoint/`、`active-tasks.md`
- ❌ 覆盖 `coverage/`、`themes/`、`briefings/` 下已有内容
- ❌ 重写整个 `AGENTS.md` / `CLAUDE.md`
- ❌ 把“升级框架”误做成“重建 workspace”

如果你发现“框架文件”和“用户资产”混在一起，无法安全自动判断：

- 先停下来
- 列出冲突文件
- 等用户确认后再继续

---

## 给用户的最短升级口令

以下任一句都可以：

- **"读 `~/investor-harness/UPGRADE-PROMPT.md`，帮我保守升级到 v0.9.8。"**
- **"按 investor-harness 的保守升级规则，把我本地版本升级到 v0.9.8，保留我的配置和任务底稿。"**
- **"帮我升级 investor-harness，但不要重装，只更新框架，保留我原来的工作区和个性化设置。"**
