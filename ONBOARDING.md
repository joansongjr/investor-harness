# Investor Harness · 首次启动引导（Onboarding）

> 用户**首次安装 investor-harness 后第一次启动 AI agent** 时，agent 应该读这份文件并按以下流程引导用户。
>
> 这份文件**同时是给 LLM 看的执行指令** 和 **给用户看的功能清单**。

---

## 🔄 已安装用户：升级入口

如果用户**已经安装过** investor-harness，这次不是首次激活，而是想把本地框架**保守升级到 v0.9.6**，同时保留：

- 个性化设置
- `user-templates/` / `user-skills/`
- 工作区
- `.task-pulse` / `active-tasks.md`
- 历史研究底稿和归档

不要把这类请求当成首次 onboarding，也不要直接重跑 bootstrap 或重写整个入口文件。

默认让用户对 agent 说：

> **"读 `~/investor-harness/UPGRADE-PROMPT.md`，然后帮我把本地 investor-harness 保守升级到 v0.9.6。"**

详细升级规则见 [`UPGRADE-PROMPT.md`](UPGRADE-PROMPT.md)。

---

## 给 LLM 的执行指令（你正在读这段，意味着你是 agent）

### 第 0 步 · 是否已经 onboard？

在向用户展示任何内容前，先检测：

```bash
# 用 grep 检查用户当前 harness 的入口 MD 是否已经包含 marker
# Claude Code: ~/.claude/CLAUDE.md
# Codex / OpenAI Agents: ~/.codex/AGENTS.md
# OpenCode: ~/.config/opencode/AGENTS.md
# OpenClaw: 类似 ~/.openclaw/CLAUDE.md（按用户实际路径）
# 项目级覆盖: {workspace}/CLAUDE.md or {workspace}/AGENTS.md

grep -l "investor-harness:keyword-routes" \
    ~/.claude/CLAUDE.md \
    ~/.codex/AGENTS.md \
    ~/.config/opencode/AGENTS.md \
    ./CLAUDE.md ./AGENTS.md 2>/dev/null
```

- **命中 marker** → 路由已经激活，但**先不要立刻宣布 onboarding 完成**。继续执行 **第 0.5 步 · 工作区骨架审计**：
  - 如果当前工作区的落盘骨架也完整 → 简短说一句"investor-harness 已激活（vX.X.X），工作区骨架已就绪，需要更新关键词路由请说'重新跑 onboarding'"，然后正常工作。
  - 如果缺少覆盖池 / 任务持久化 / 归档目录 → 明确告诉用户"当前只是路由接通，工作区还是空书架"，继续第 7 步补建。
- **未命中** → 继续第 1 步。

### 第 0.5 步 · 工作区骨架审计（新增硬约束）

在当前目录（或用户指定的 investor workspace）检查以下对象：

**硬性文件**：
- `AGENTS.md` 或 `CLAUDE.md`
- `memory.md`
- `coverage.md`
- `active-tasks.md`
- `.task-pulse`

**硬性目录**：
- `.checkpoint/`
- `coverage/`
- `themes/`
- `briefings/`

**强烈建议但可后补**：
- `user-templates/`
- `user-skills/`

**规则**：

- **缺任何硬性项** → 不能说 onboarding 完成
- 要明确告诉用户："Investor Harness 现在只是把路由块装上了，但覆盖池 / 归档 / 任务续跑体系还没落地"
- 默认补建方式：运行 `bash {HARNESS_PATH}/setup/bootstrap.sh {workspace_root}`
- **只补缺，不覆盖现有文件**
- 如需覆盖现有文件，必须再次征得用户明确同意

### 第 1 步 · 展示功能清单 + 关键词表

向用户**完整**展示以下两段（不要省略）：

> 你装了 **Investor Harness**——投研人的 AI 任务执行规范。下面是它能帮你做的事 + 对应触发关键词。
>
> **31 个 sm-* skill，分 11 大类**：
>
> ▸ **入口路由**（2）：`sm-autopilot`（模糊请求自动判断走哪个）/ `sm-master`（7 模式总控）
> ▸ **命题与框架**（2）：`sm-thesis`（投资命题）/ `sm-industry-map`（行业框架 + 空间测算 + 环节壁垒）
> ▸ **单点研究**（6）：`sm-company-deepdive`（公司深度 13 段：壁垒五维量化 + 量价拆分）/ `sm-valuation`（估值方法选择 + 同业对比，v0.9.5）/ `sm-earnings-preview`（财报前瞻）/ `sm-model-check`（模型审阅）/ `sm-consensus-watch`（一致预期 + 预期差）/ `sm-industry-database`（产业 / 公司数据库搭建）
> ▸ **跟踪监控**（5）：`sm-catalyst-monitor`（催化剂事件）/ `sm-roadshow-questions`（路演调研问题）/ `sm-catalyst-sweep`（覆盖池催化扫描）/ `sm-hourly-watch`（小时级盯盘）/ `sm-close-recap`（收盘复盘）
> ▸ **反方挑战**（1）：`sm-red-team`（空头逻辑 / 反方审视）
> ▸ **选股发现**（1）：`sm-stock-screen`（选股 / 主题筛标的）
> ▸ **输出交付**（3）：`sm-pm-brief`（PM 一页纸）/ `sm-briefing`（晨会 / 晚报 / 纪要）/ `sm-deck-builder`（PPT 生成）
> ▸ **技术面**（2）：`sm-tape-review`（K 线 + 量价复盘）/ `sm-quant-tape`（量化看盘 · 缠论结构，v0.9.5）
> ▸ **三方任务组**（1，v0.9.6）：`sm-supervisor`（在第二任务开启实时语音，作为第三方监工监督 worker：随时问进度、抽查可靠性、口头下达修正、需要时请用户仲裁）
> ▸ **批量**（2）：`sm-batch-refresh`（覆盖池批量刷新）/ `sm-batch-earnings`（财报季批量）
> ▸ **🆕 Librarian 模式**（6，v0.9+，opt-in）：`sm-wiki-build`（建 14 段 wiki）/ `sm-daily-feed`（7 桶日刷）/ `sm-question-list`（会前 vault 扫描）/ `sm-health-check`（健康检查 + 跨源仲裁）/ `sm-qa-archive`（会后归档 + 双链）/ `sm-people-watch`（关键人物 / Reddit / X 跟踪）

然后展示完整路由表（从 [`setup/keyword-routes.md`](setup/keyword-routes.md) 拉，用 markdown 表格呈现，**至少包含每个 skill 一行**——不允许省略）。

展示 `sm-supervisor` 时必须补一句实际启动方式：

> “任务 A 正常跑研究；任务 B 进入同一工作区并开启实时语音，说‘用 sm-supervisor 监工 X’，两边通过 `.supervision/` 双向 mailbox 协作。语音监工不写正文，只负责进度、质检、干预和仲裁。”

### 第 2 步 · 解释三种激活方式

> **怎么用这些关键词？三种方式**：
>
> 1. **🚀 推荐：自动激活路由（一键写入入口 MD）**
>    我把这张路由表写入你 AI agent 的入口 MD 文件（Claude Code → `~/.claude/CLAUDE.md`；Codex → `~/.codex/AGENTS.md` 等）。
>    下次你说"看看 X"或"深度看 X"或"反过来想 X"，AI 自动按对应 skill 工作，不用你每次手动说"用 sm-xxx 跑"。
>
> 2. **手动复制**
>    自己把 [`setup/routes-block.template.md`](setup/routes-block.template.md) 整块复制到你的入口 MD（适合想自己审一遍内容的用户）。
>
> 3. **每次显式调用**
>    不写入路由，每次手动说"用 sm-company-deepdive 跑 NVDA"。最透明但最啰嗦。

### 第 3 步 · 请求明确同意（硬约束 ⛔）

向用户精确询问：

> 选哪种方式？如果选 **方式 1（自动激活）**，请输入 **"同意"**——我会：
>
> 1. 检测你当前的 AI agent 类型（Claude Code / Codex / OpenCode / OpenClaw / 其他）
> 2. 找到对应的入口 MD 路径
> 3. 在文件末尾追加路由块（用 `<!-- investor-harness:keyword-routes:start -->` 包住，将来升级可整块替换）
> 4. **不会**改任何已有内容
>
> 如果选其他方式，告诉我你选 2 还是 3，我就跳过。
> 不输入"同意"则**默认不写**——你可以现在就开始用 sm-* skill 名直接调用。

#### ⛔ 硬约束（LLM 必须遵守）

- **必须**等到用户输入精确的"同意" / "agree" / "yes, write it" / "OK 写入"等明确表达**之后**，才能 Edit/Write 任何入口 MD 文件
- 用户说"先看看" / "稍等" / "再想想" / "我自己来" / 任何不明确的回复 → **绝对不写入**
- 用户问"会改什么文件" / "块长什么样" → 先 dry-run 展示要写入的内容，**等用户再次明确同意**

### 第 4 步 · 检测 harness + 入口 MD 路径

用户输入"同意"后，按以下顺序探测入口 MD（用 `ls` / `test -f`，不要靠猜）：

| 优先级 | harness | 路径 | 用户级 vs 项目级 |
|---|---|---|---|
| 1 | 项目级 Claude Code | `${PWD}/CLAUDE.md` | 项目（最具体）|
| 2 | 项目级 Codex/Agents | `${PWD}/AGENTS.md` | 项目 |
| 3 | 用户级 Claude Code | `~/.claude/CLAUDE.md` | 用户全局 |
| 4 | 用户级 Codex | `~/.codex/AGENTS.md` | 用户全局 |
| 5 | 用户级 OpenCode | `~/.config/opencode/AGENTS.md` | 用户全局 |
| 6 | 用户级 OpenClaw | `~/.openclaw/CLAUDE.md`（推测）| 用户全局 |

**规则**：

- 用户当前**在项目目录下** + 项目级 MD 存在 → **优先写项目级**（影响范围窄、易回滚）
- 否则 → 写**用户级**
- 多个 harness 都装了 → 询问用户写哪个 / 全部都写
- 一个都没检测到 → 询问用户手动给路径

### 第 5 步 · 写入路由块

```
1. 读取目标 MD 文件
2. 如果已有 <!-- investor-harness:keyword-routes:start --> ... :end --> 块
   → 整块替换（保留 marker 外的所有内容）
3. 如果没有
   → 在文件末尾追加一行空行 + 整块路由（来自 setup/routes-block.template.md）
4. 把 INVESTOR_HARNESS_PATH 占位符替换为实际安装路径（如 ~/investor-harness 或 /opt/investor-harness）
5. 用户确认看到 📁 已写入 X 文件 + 重启 agent 即可生效
```

⛔ 写入前必须再次显示：

```
即将写入：
  目标文件: ~/.claude/CLAUDE.md
  块大小: ~80 行
  marker: <!-- investor-harness:keyword-routes:start v0.9.6 -->
  会保留: marker 外的所有现有内容
确认写入？输入"确认"或"算了"。
```

只有用户再次输入"确认"才执行 Edit/Write。

### 第 6 步 · 写入后验证

```bash
# 用 grep 验证 marker 写入成功
grep -c "investor-harness:keyword-routes" <target_md>
# 应该返回 2（start + end）
```

输出给用户：

> ✅ 已写入 `~/.claude/CLAUDE.md`（追加 ~80 行，未改动已有内容）
> 📁 路由块版本：v0.9.6
> 🔄 **重启你的 AI agent**（重开一个 claude / codex 会话）即可生效
>
> 验证方式：重启后说"看看 NVDA"，agent 会自动按 `sm-autopilot` 工作（而不是裸 LLM 乱答）。
>
> 想未来更新路由表？说"重新跑 investor-harness onboarding"。

### 第 7 步 · 工作区补建（首次必须做完）

> **路由激活 ≠ 工作区可用。**
> 只把关键词路由写进入口 MD，但没有 coverage/、.task-pulse、active-tasks.md 的工作区，等于"书架装好了，但一本书都没上架"。

在第 0.5 步发现缺口时，按以下顺序执行：

1. 确认工作区路径
   - 优先当前项目目录
   - 如果当前目录显然不是投研工作区，询问用户要用哪个目录
2. 向用户展示缺口清单（缺哪些文件 / 目录）
3. 询问用户：

> 检测到当前工作区缺少 coverage / 任务持久化骨架。  
> 输入 **"补建"**，我会运行：
>
> `bash {HARNESS_PATH}/setup/bootstrap.sh {workspace_root}`
>
> 只新增缺失项，不覆盖已有文件。

4. 只有用户明确输入 `"补建"` / `"同意补建"` 后，才执行 bootstrap
5. bootstrap 执行完后，重新审计一遍第 0.5 步的清单
6. 只有硬性文件 + 硬性目录全部存在，才能对用户说 onboarding 完成

### 第 8 步 · 覆盖池归档硬约束（写进规范）

完成 onboarding 后，向用户明确说明以下规则：

- **⛔ 置顶规则（写入入口 MD 时必须包含）**：任何任务开工前，agent 先调用用户本地电脑里已有的全部相关资料（手稿 / 笔记 / 规范 / 模板 / 模型 / 纪要 / 归档），并把用户本地规范当作**最高优先级的要求来源**——高于 harness 默认方法论与外部数据；本地已有研究是工作起点，不做重复劳动

- 以后**任何单公司 / 覆盖池相关任务**，输出都必须同时：
  - 贴在对话里给用户直接读
  - 归档到对应目录：`{coverage_root}/{ticker}_{name}/...`
- 如果该 ticker 目录还不存在，agent 必须在 **preamble 阶段**先创建目录和 `INDEX.md`，**不能**等到最后才想起落盘
- 如果结果只存在于对话里、没有进入 `coverage/{ticker}_{name}/`，这次任务视为**未完成**
- 公司级任务完成后，至少要更新：
  - 该 ticker 的 `INDEX.md`
  - `.task-pulse`
  - `active-tasks.md`

### 第 9 步 · onboarding 完成的定义（新的完成标准）

只有同时满足以下两件事，才能说"Investor Harness 已经 setup 好"：

1. **入口路由已激活**（入口 MD 已写入 marker）
2. **工作区骨架已就绪**（coverage/、themes/、briefings/、.task-pulse、active-tasks.md、coverage.md、memory.md 等已存在）

缺任何一项，都要明确告诉用户：

> 你现在不是"已经 setup 完"，
> 而是"路由通了，但覆盖池和归档系统还没落地"。

---

## 给用户的快速参考（你也可以自己读）

### 你装的是什么

**Investor Harness v0.9.6** — 投研人的 AI 任务执行规范。开源，MIT 协议。
GitHub: https://github.com/joansongjr/investor-harness

### 它解决的问题

- ❶ **幻觉**：AI 不再编数据——每条事实必须标完整中文证据等级、列"仍需补的资料"
- ❷ **健忘**：跨 session 续跑、覆盖池持久化
- ❸ **不成体系**：31 个标准化 skill，所有输出归档到固定路径
- ❹ **上下文溢出**：三层加载 + checkpoint 续跑
- ❺ **🆕 被动**（v0.9 Librarian 解决）：AI 不再只是"你问什么它答什么"——每天主动扫 vault、刷新 wiki、跑健康检查

### 关键词路由表

见上方第 1 步，或完整版：[`setup/keyword-routes.md`](setup/keyword-routes.md)

### 不想自动写入路由也可以这么用

每次手动调用：

```
你：用 sm-company-deepdive 跑 NVDA
你：用 sm-red-team 反过来想 NVDA 多头逻辑
你：用 sm-wiki-build 给 NVDA 起 wiki page
你：用 sm-hourly-watch 盯一下我的股票池
```

效果一样，只是每次要打 skill 名。

### 想退出 / 移除路由

让 agent 帮你删 marker 之间的块：

> "请把 ~/.claude/CLAUDE.md 里的 investor-harness 路由块删掉"

agent 会找 marker 然后整块移除，不动其他内容。

### 想升级路由表

```
你：重新跑 investor-harness onboarding
```

agent 读这份文件，检测到已 onboard 后会问你要不要刷新到最新版本——同意后整块替换。

### 想升级整个框架（不是只换路由）

如果你已经安装过 investor-harness，想把本地框架升级到新版本，同时保留原来的工作区、任务底稿和个性化设置，对 agent 说：

```
你：读 ~/investor-harness/UPGRADE-PROMPT.md，然后帮我把本地 investor-harness 保守升级到 v0.9.6
```

agent 会按 `UPGRADE-PROMPT.md` 的规则执行：先做升级审计，再增量更新框架层，只替换 marker 内的入口块，保留用户资产，不做重装。
