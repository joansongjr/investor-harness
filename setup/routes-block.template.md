<!-- investor-harness:keyword-routes:start v0.9.6 -->
<!--
  这块由 investor-harness ONBOARDING.md 自动管理。
  下次升级时整块替换。**不要手动编辑**——改 setup/keyword-routes.md 然后重跑 onboarding。
  Source: https://github.com/joansongjr/investor-harness/blob/main/setup/keyword-routes.md
-->

## Investor Harness 关键词路由（自动注入）

当用户对话里出现以下关键词时，**LLM 必须按对应 skill 的规则工作**（按 core/_boot.md 三层加载）：

### 默认路由（25 个）

| 用户说 | 走 skill |
|---|---|
| 看看 X / X 怎么样 / 帮我看下 X | `sm-autopilot`（模糊路由） |
| master 模式 / 总控 / 全套跑一遍 X | `sm-master` |
| X 投资命题 / X 的 thesis / X 投资逻辑 | `sm-thesis` |
| X 行业框架 / X 产业链地图 / X 行业全景 | `sm-industry-map` |
| **X 深度报告 / 深度看 X / 起 X 的 coverage** | `sm-company-deepdive` |
| **X 财报前瞻 / X earnings preview / X 业绩前瞻** | `sm-earnings-preview` |
| 审 X 的模型 / X 模型 sanity check / X 模型审阅 | `sm-model-check` |
| **X 预期差 / X consensus / X 一致预期** | `sm-consensus-watch` |
| 数据库 / 产业数据库 / 公司数据库 / 数据底表 / 指标库 | `sm-industry-database` |
| **X 估值 / X 贵不贵 / X 怎么估 / X 同业估值对比** | `sm-valuation` |
| X 催化剂 / X catalyst / X 事件跟踪 | `sm-catalyst-monitor` |
| 怎么问 X 管理层 / X 调研提纲 / X 路演问题 | `sm-roadshow-questions` |
| 盯盘 / 看盘 / 每小时看一下 X / X 盘中异动 | `sm-hourly-watch` |
| 收盘后复盘 / 股票池复盘 / 今天为什么涨跌 / 盘后复盘 | `sm-close-recap` |
| **反过来想 X / X 空头逻辑 / X red team / X 反方** | `sm-red-team` |
| 选股 / 筛标的 / 挖标的 / AI 链里还缺什么 / 涨得少的 AI 板块 | `sm-stock-screen` |
| **给 PM 一页纸 / X 的 PM brief / IC 一页纸** | `sm-pm-brief` |
| 晨会 / 晚报 / 整理今天的 X / 路演摘要 | `sm-briefing` |
| 看 X 的 K 线 / 复盘 X / X 盘面 / X 技术面 | `sm-tape-review` |
| **量化看盘 / X 缠论 / X 的缠论结构 / X 买卖点 / X 中枢 / X 背驰** | `sm-quant-tape` |
| **做 X 的 deck / X 的 IC pitch PPT / X 路演 PPT / X 客户 pitch** | `sm-deck-builder` |
| 刷新覆盖池 / 批量过 X 列表 / coverage refresh | `sm-batch-refresh` |
| 财报季批量 / 批量前瞻 / batch earnings | `sm-batch-earnings` |
| 扫事件 / 今天有什么催化 / catalyst sweep | `sm-catalyst-sweep` |
| **监工 X / 盯着 X 的任务 / 开个监工 / 三方任务组** | `sm-supervisor` |

### Librarian 模式（v0.9+ · opt-in · 6 个）

> 仅当用户明示以下关键词时启用，**不在 sm-autopilot 默认路由内**。

| 用户说 | 走 skill |
|---|---|
| **起 X 的 wiki page / 建 X 的 coverage / onboard X** | `sm-wiki-build` |
| **刷 daily feed / 跑每日扫描 / 今天看一下覆盖池** | `sm-daily-feed` |
| **见 X 前过一遍 question list / 准备 X 调研提纲 / 会前 briefing** | `sm-question-list` |
| **跑健康检查 / 扫跨源矛盾 / wiki 自检** | `sm-health-check` |
| **会后归档 / 整理 X 的 Q&A / 见完 X 后整理** | `sm-qa-archive` |
| **关键人物追踪 / 关键人物观点 / X观点 / X 观点 / 外网观点 / 外网怎么说 / 海外社区怎么看 / 推特观点 / Reddit 观点 / 外网情绪 / 跟踪 X 博主 / 跟踪 Reddit / 人物 watch** | `sm-people-watch` |

### 硬约束（所有路由都强制）

0. **⛔ 置顶：本地资料优先**——任何任务开工、调用任何外部数据源之前，先扫描并调用用户本地电脑里已有的全部相关资料（手稿 / 笔记 / 规范 / 模板 / 模型 / 纪要 / 归档产出）。用户本地规范与要求是**最高优先级的要求来源**，高于本路由表和 harness 默认方法论；本地已有研究是工作起点，不做重复劳动。[Preflight] 必须列出扫描到的本地资料清单（或写明"本地无相关资料"）
1. 如果当前工作区缺少 `coverage/` / `themes/` / `briefings/` / `.task-pulse` / `active-tasks.md`，先提示用户补建；**只装路由不算 setup 完成**
2. 开始前：跑 [`core/preamble.md`](INVESTOR_HARNESS_PATH/core/preamble.md) 6 步
3. 输出时：每条事实带证据等级（公开事实 / 财报披露 / 市场共识 / 合理推演 / 待核验假设）
4. 结束后：跑 [`core/postamble.md`](INVESTOR_HARNESS_PATH/core/postamble.md) 8 步
5. 覆盖池 / 单标的任务必须归档到 `{coverage_root}/{ticker}_{name}/...`，只留在对话里视为未完成
6. 双输出：对话贴完整内容 + 写入文件，末尾追加 📁 已归档提示

⛔ 不编数据 · 不当替代持牌分析师 · 不构成买卖建议

详细 skill 文档：`INVESTOR_HARNESS_PATH/skills/{skill-name}/SKILL.md`
完整路由表：`INVESTOR_HARNESS_PATH/setup/keyword-routes.md`

<!-- investor-harness:keyword-routes:end -->
