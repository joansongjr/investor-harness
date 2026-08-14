# 用户知识库锚点（自动写入入口文件最顶层）

> ⚠️ **这个块不是 marker 追加的，是插入到文件最顶层的**——保证每次新会话 agent 第一件事读到知识库路径与规范。
>
> 来源：用户消息触发语句 "我的知识库在 XX_FOLDER 文件夹存着，按照 harness 的规范，每次都调用里面的内容，并且把生成的结果存在这个文件夹里对应的位置，把这个位置和这段要求放在 agent.md 文件最顶层"
>
> 占位符在写入时被替换：
> - `{{KB_PATH}}` → 用户指定的知识库绝对路径（如 `/Users/xxx/my-research`）
> - `{{HARNESS_PATH}}` → investor-harness 安装路径

---

# 📚 知识库锚点（最高优先级 · 不可绕过）

## 用户知识库位置

`{{KB_PATH}}`

这是用户的**唯一权威资料库**。每次任务开工前必须扫描此目录下的全部相关资料（手稿 / 笔记 / 规范 / 模板 / 模型 / 纪要 / 归档）。

## 强制规范（违反等于未完成任务）

### 1. 调用优先：每次开工先读本地
- 任何任务**开工前**（调用任何外部数据源之前），必须**先扫描并调用 `{{KB_PATH}}` 里已有的全部相关资料**
- 用户本地规范是**最高优先级的要求来源**，**高于** harness 默认方法论与外部数据
- 本地已有研究是工作起点，**不做重复劳动**
- [Preflight] 必须列出扫描到的本地资料清单（或写明"本地无相关资料"）

### 2. 结果归档：输出必须回写本地
- 任何单公司 / 覆盖池相关任务的输出，**必须同时**：
  - 贴在对话里给用户直接读（Dual Output Discipline）
  - **回写到 `{{KB_PATH}}` 里对应的位置**（如 `{{KB_PATH}}/coverage/{ticker}_{name}/...` 或 `{{KB_PATH}}/themes/...` 或 `{{KB_PATH}}/briefings/...`）
- 如果该 ticker / 主题目录还不存在，**preamble 阶段先创建**，不能等到最后才落盘
- 如果结果只存在于对话里、没有进入 `{{KB_PATH}}` 对应位置 → 这次任务视为**未完成**

### 3. 关键行动：路径与本要求放在入口文件**最顶层**
- 本块（含本段）**必须**位于 agent.md / CLAUDE.md / AGENTS.md / system prompt 的**最顶层**（不是追加到末尾）
- 原因：每次新会话第一件事读到知识库路径与规范，agent 第一时间知道从本地资料出发
- 如果未来升级 investor-harness，整块路由表替换/移除时**不动**本块（它独立于 marker 路由系统）

### 4. 持续同步：保持一致性
- 任务结束后，必须更新：
  - 该 ticker / 主题的 INDEX.md（如有）
  - `{{KB_PATH}}` 根目录下的任务进度文件（如 `active-tasks.md` 或 `.task-pulse`）
- 保持 `{{KB_PATH}}` 与 harness 的工作流一致

## 与 harness 的协作关系

| 维度 | 关系 |
|---|---|
| **数据来源优先级** | 本地知识库 (`{{KB_PATH}}`) > harness 默认方法论 > 外部数据源 |
| **触发一致性** | 任何 sm-* skill 被调用时，第一步都是扫描 `{{KB_PATH}}` |
| **归档一致性** | 任何 sm-* skill 完成后，最后一步都是回写到 `{{KB_PATH}}` 对应位置 |
| **覆盖关系** | 如果知识库里的本地规范与 harness 文档冲突，**以知识库为准** |

## 安装位置

harness 安装路径：`{{HARNESS_PATH}}`

详细 skill 文档：`{{HARNESS_PATH}}/skills/{skill-name}/SKILL.md`
核心方法论：`{{HARNESS_PATH}}/core/`
升级指南：`{{HARNESS_PATH}}/UPGRADE-PROMPT.md`

---

<!-- investor-harness:knowledge-base-anchor:start v0.9.7 -->
<!-- 这个 marker 让 harness 升级时能识别锚点块，但锚点本身始终在最顶层，不参与路由替换 -->
<!-- investor-harness:knowledge-base-anchor:end -->