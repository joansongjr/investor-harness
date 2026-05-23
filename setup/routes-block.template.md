<!-- investor-harness:keyword-routes:start v0.9.1 -->
<!--
  这块由 investor-harness ONBOARDING.md 自动管理。
  下次升级时整块替换。**不要手动编辑**——改 setup/keyword-routes.md 然后重跑 onboarding。
  Source: https://github.com/joansongjr/investor-harness/blob/main/setup/keyword-routes.md
-->

## Investor Harness 关键词路由（自动注入）

当用户对话里出现以下关键词时，**LLM 必须按对应 skill 的规则工作**（按 core/_boot.md 三层加载）：

### 默认路由（18 个）

| 用户说 | 走 skill |
|---|---|
| 看看 X / X 怎么样 / 帮我看下 X | `sm-autopilot`（模糊路由） |
| 总控 / 全套跑 X | `sm-master` |
| X 投资命题 / X 的 thesis / X 投资逻辑 | `sm-thesis` |
| X 行业框架 / X 产业链 / X 行业全景 | `sm-industry-map` |
| **X 深度报告 / 深度看 X / 起 X 的 coverage** | `sm-company-deepdive` |
| **X 财报前瞻 / X earnings preview** | `sm-earnings-preview` |
| 审 X 的模型 / X 模型 sanity check | `sm-model-check` |
| **X 预期差 / X consensus / X 一致预期** | `sm-consensus-watch` |
| X 催化剂 / X 事件跟踪 | `sm-catalyst-monitor` |
| 怎么问 X 管理层 / X 调研提纲 / X 路演问题 | `sm-roadshow-questions` |
| **反过来想 X / X 空头逻辑 / X red team / X 反方** | `sm-red-team` |
| **给 PM 一页纸 / X 的 PM brief / IC 一页纸** | `sm-pm-brief` |
| 晨会 / 晚报 / 整理今天的 X / 路演摘要 | `sm-briefing` |
| 看 X 的 K 线 / 复盘 X / X 盘面 | `sm-tape-review` |
| **做 X 的 deck / X 的 IC pitch PPT / X 路演 PPT** | `sm-deck-builder` |
| 刷新覆盖池 / coverage refresh | `sm-batch-refresh` |
| 财报季批量 / batch earnings | `sm-batch-earnings` |
| 扫事件 / 今天有什么催化 | `sm-catalyst-sweep` |

### Librarian 模式（v0.9 · opt-in · 5 个）

> 仅当用户明示以下关键词时启用，**不在 sm-autopilot 默认路由内**。

| 用户说 | 走 skill |
|---|---|
| **起 X 的 wiki page / 建 X 的 coverage / onboard X** | `sm-wiki-build` |
| **刷 daily feed / 跑每日扫描 / 今天看一下覆盖池** | `sm-daily-feed` |
| **见 X 前过一遍 question list / 会前 briefing** | `sm-question-list` |
| **跑健康检查 / 扫跨源矛盾 / wiki 自检** | `sm-health-check` |
| **会后归档 / 整理 X 的 Q&A / 见完 X 后整理** | `sm-qa-archive` |

### 硬约束（所有路由都强制）

1. 开始前：跑 [`core/preamble.md`](INVESTOR_HARNESS_PATH/core/preamble.md) 6 步
2. 输出时：每条事实带证据等级（公开事实 / 财报披露 / 市场共识 / 合理推演 / 待核验假设）
3. 结束后：跑 [`core/postamble.md`](INVESTOR_HARNESS_PATH/core/postamble.md) 8 步
4. 双输出：对话贴完整内容 + 写入文件，末尾追加 📁 已归档提示

⛔ 不编数据 · 不当替代持牌分析师 · 不构成买卖建议

详细 skill 文档：`INVESTOR_HARNESS_PATH/skills/{skill-name}/SKILL.md`
完整路由表：`INVESTOR_HARNESS_PATH/setup/keyword-routes.md`

<!-- investor-harness:keyword-routes:end -->
