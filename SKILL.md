---
name: investor-harness
description: 投研任务执行规范总入口 + onboarding 激活引导（WorkBuddy 专用）。当用户说"跑一下 investor-harness onboarding"、"激活 investor-harness"、"引导我激活"、"重新跑 onboarding"，或提出二级市场投研类请求（看股票/深度研究/财报前瞻/反方审视/估值/盯盘/复盘/选股/晨会晚报/路演提纲/数据库/PPT 等）时使用本 skill。按关键词路由表匹配对应 sm-* skill 并执行，强制 preamble/postamble/证据分级/归档硬约束。
agent_created: true
---

# Investor Harness · WorkBuddy 总入口

本 SKILL.md 所在目录即 investor-harness 根目录。`core/` 和 `skills/` 都在此目录下。

本 skill 是 investor-harness 在 WorkBuddy 环境下的"自动调用规范"入口，等同 `sm-autopilot` + onboarding 引导。原版 onboarding 靠写 `~/.claude/CLAUDE.md` 激活，**WorkBuddy 不读该文件**——WorkBuddy 靠本 SKILL.md 的 `description` 自动匹配触发，无需写入入口 MD。

## 第 0 步 · 判断本次意图

- 用户说"onboarding / 激活 / 引导激活 / 重新跑 onboarding" → 走 **onboarding 流程**（第 1~9 步）
- 用户提投研请求（看 X / 深度看 X / 财报前瞻 / 反过来想 X 等）→ 跳到 **关键词路由表** 匹配 sm-* skill 执行
- 模糊不清 → 先确认是"激活引导"还是"直接做研究"

## onboarding 流程（WorkBuddy 适配版）

### 第 1 步 · 展示功能清单 + 关键词表
读 `ONBOARDING.md` 第 1 步的 32 个 skill 清单，完整展示给用户（不省略）。完整路由表从 `setup/keyword-routes.md` 拉。

### 第 2 步 · 解释 WorkBuddy 下的激活方式
> 本项目在 WorkBuddy 下已通过「根目录 SKILL.md」自动激活——WorkBuddy 扫描 `~/.workbuddy/skills/investor-harness/SKILL.md` 即识别为本 skill，按 description 自动触发。无需写入口 MD。可选增强：把路由表写入 `~/.workbuddy/MEMORY.md`（用户级）或 `{workspace}/.workbuddy/memory/MEMORY.md`（项目级）做持久底座。

### 第 3 步 · 请求明确同意（硬约束 ⛔）
- 必须等到用户输入"同意 / agree / yes, write it / OK 写入"等明确表达后，才能写任何文件
- "先看看 / 再想想 / 我自己来" → 绝对不写
- 可先 dry-run 展示要写入的内容，等用户再次明确同意

### 第 4 步 · 检测目标位置
WorkBuddy 环境下，路由底座写入目标：
- 用户级：`~/.workbuddy/MEMORY.md`（跨项目生效）
- 项目级：`{workspace}/.workbuddy/memory/MEMORY.md`（仅当前项目）
- 优先项目级（影响范围窄、易回滚）；无项目上下文则写用户级
- 不再探测 `~/.claude/CLAUDE.md` / `~/.codex/AGENTS.md`（WorkBuddy 不读）

### 第 5 步 · 写入路由底座（可选增强）
1. 读 `setup/routes-block.template.md`
2. 读目标 MEMORY.md（若不存在则视为空）
3. 若已有 `<!-- investor-harness:keyword-routes:start -->...:end -->` 块 → 整块替换
4. 若没有 → 在文件末尾追加空行 + 路由块（把 `INVESTOR_HARNESS_PATH` 替换为实际安装路径）
5. 写入前再次 dry-run 显示目标路径 + 块大小 + marker，等用户输入"确认"才执行
6. 若用户选择"只靠 SKILL.md 自动触发，不写 MEMORY.md" → 跳过本步，onboarding 仍算完成

### 第 6 步 · 写入后验证
若写了 MEMORY.md：`grep -c "investor-harness:keyword-routes" <target>` 应返回 2。告知用户重启 WorkBuddy 会话即可生效。验证方式：新会话说"看看 NVDA"，agent 应自动按 sm-autopilot 工作。

### 第 7 步 · 工作区骨架审计（首次必须做完）
检测当前工作区硬性项：`coverage.md` / `active-tasks.md` / `.task-pulse` / `coverage/` / `themes/` / `briefings/` / `.checkpoint/`。缺任何硬性项 → 不能说 onboarding 完成。征得用户输入"补建"后运行 `bash setup/bootstrap.sh {workspace_root}`，只补缺不覆盖。

### 第 8 步 · 归档硬约束
任何单公司/覆盖池任务输出必须同时：贴对话 + 归档到 `{coverage_root}/{ticker}_{name}/...`。ticker 目录不存在时 preamble 阶段先创建。只留对话未落盘 = 任务未完成。

### 第 9 步 · onboarding 完成标准
同时满足：① WorkBuddy 已识别本 skill（`~/.workbuddy/skills/investor-harness/SKILL.md` 存在）② 工作区骨架就绪。MEMORY.md 路由底座为可选增强，不写入也算完成。

## 关键词路由表（执行投研任务时用）

完整表见 `setup/keyword-routes.md`。匹配到关键词后，**Read 对应 `skills/{skill-name}/SKILL.md` 并按其规则工作**。默认路由 26 条 + Librarian opt-in 6 条。常用映射：

| 用户说 | Read skill |
|---|---|
| 看看 X / X 怎么样 / 帮我看下 X | `skills/sm-autopilot/SKILL.md` |
| master 模式 / 总控 / 全套跑一遍 X | `skills/sm-master/SKILL.md` |
| X 投资命题 / thesis | `skills/sm-thesis/SKILL.md` |
| X 行业框架 / 产业链地图 | `skills/sm-industry-map/SKILL.md` |
| 深度看 X / 起 X 的 coverage | `skills/sm-company-deepdive/SKILL.md` |
| X 财报前瞻 / earnings preview | `skills/sm-earnings-preview/SKILL.md` |
| 审 X 的模型 / 模型 sanity check | `skills/sm-model-check/SKILL.md` |
| X 预期差 / consensus / 一致预期 | `skills/sm-consensus-watch/SKILL.md` |
| 数据库 / 产业数据库 / 指标库 | `skills/sm-industry-database/SKILL.md` |
| X 估值 / X 贵不贵 / 同业估值对比 | `skills/sm-valuation/SKILL.md` |
| X 催化剂 / catalyst / 事件跟踪 | `skills/sm-catalyst-monitor/SKILL.md` |
| 怎么问 X 管理层 / 路演问题 | `skills/sm-roadshow-questions/SKILL.md` |
| 盯盘 / 每小时看 X / 盘中异动 | `skills/sm-hourly-watch/SKILL.md` |
| 收盘复盘 / 今天为什么涨跌 | `skills/sm-close-recap/SKILL.md` |
| 反过来想 X / X 空头逻辑 / red team | `skills/sm-red-team/SKILL.md` |
| 选股 / 筛标的 / 挖标的 | `skills/sm-stock-screen/SKILL.md` |
| 给 PM 一页纸 / IC 一页纸 | `skills/sm-pm-brief/SKILL.md` |
| 晨会 / 晚报 / 路演摘要 | `skills/sm-briefing/SKILL.md` |
| 看 X 的 K 线 / X 技术面 | `skills/sm-tape-review/SKILL.md` |
| 量化看盘 / X 缠论 / 买卖点 / 中枢 | `skills/sm-quant-tape/SKILL.md` |
| 做 X 的 deck / IC pitch PPT | `skills/sm-deck-builder/SKILL.md` |
| 刷新覆盖池 / coverage refresh | `skills/sm-batch-refresh/SKILL.md` |
| 财报季批量 / batch earnings | `skills/sm-batch-earnings/SKILL.md` |
| 扫事件 / catalyst sweep | `skills/sm-catalyst-sweep/SKILL.md` |
| 监工 X / 三方任务组 / 语音监工 | `skills/sm-supervisor/SKILL.md` |
| 归纳提问 / 学习我的问法 / 撤销 L-xxx | `skills/sm-learn/SKILL.md` |

Librarian 模式（opt-in，需明示）：起 wiki page → `sm-wiki-build` · 刷 daily feed → `sm-daily-feed` · 会前 question list → `sm-question-list` · 跑健康检查 → `sm-health-check` · 会后归档 → `sm-qa-archive` · 关键人物追踪 / 外网观点 → `sm-people-watch`

## 硬约束（所有路由强制）

0. ⛔ **本地资料优先**——开工前先扫描用户本地已有资料（手稿/笔记/模板/归档），本地规范是最高优先级要求来源，不做重复劳动
1. 工作区缺骨架先提示补建，只装路由不算 setup 完成
2. 开始前跑 `core/preamble.md` 6 步
3. 输出每条事实带证据等级（公开事实 / 财报披露 / 市场共识 / 合理推演 / 待核验假设）
4. 结束后跑 `core/postamble.md` 8 步
5. 覆盖池/单标的任务必须归档到 `{coverage_root}/{ticker}_{name}/...`
6. 双输出：对话贴完整内容 + 写文件，末尾追加 📁 已归档提示

⛔ 不编数据 · 不当替代持牌分析师 · 不构成买卖建议

## 升级方式
重新跑 onboarding（说"跑一下 investor-harness onboarding"）刷新 MEMORY.md marker 内的块，或读 `UPGRADE-PROMPT.md` 升级整个框架。
