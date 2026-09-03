# Investor Harness · Boot

> 🚀 每次新会话第一个读的文件。**< 1k tokens**。其他 core/* 按需懒加载。

## What this is

Investor Harness v0.9.9 — 投研人的 AI 任务执行规范。
治三大痛点：**幻觉 / 健忘 / 不成体系**。
**v0.9.5 深度研究升级**：deepdive 壁垒五维量化 + 量价拆分 + 财务指标分析；新增 `sm-valuation` 与 `sm-quant-tape`。**v0.9.6 三方任务组**：`sm-supervisor` 把第二任务的实时语音变成第三方监工——用户 + worker + supervisor 通过 `.supervision/` 双向 mailbox 协作。**v0.9.6 · deepdive 结论前置**：`sm-company-deepdive` 输出格式改为 §0 结论前置 + §1-§13 底稿，先底稿标 🔴/🟡/🟢 权重再综合 §0。**v0.9.7 自主学习**：`sm-learn` + `core/learning.md`——用户的提问方式被自动采集（postamble）、每 3-5 次会话自动归纳、按"问题回家"原则反补进对应 skill 的必答问题（overlay），自动生效进试用期，用户只保留"撤销 L-xxx"否决权。**v0.9.8 · deepdive 回归业务理解**：`sm-company-deepdive` 收为 §0 + §1-§11 共 12 段，§2 按业务线逐条展开（做什么 / 产品与客户 / 前景 / 技术变化利好利空及原因 / 近 90 天变化）成为主模块；量价拆分降为 §5 按需档（档 A 驱动方向默认，档 B 完整拆表仅在有一次源或用户明示时做，禁止拍数填表）；新增 §7 近 90 天市场争论时效段；§2 完整规格沉淀为 `core/business-line-analysis.md`（切分三层法 + 传导链六环模板 + 前景模板 + 时效规则 + 技术信息源权威度优先级）。**v0.9.9 新增两个 skill**：`sm-infographic`（一图复盘——公司财报一图 / 板块期间一图，先底稿后渲染，图上数字可溯源，含信息准确性核验块）与 `sm-fund-compare`（基金对比——同口径闸门 + 情景适配结论，不作申购推荐）。

## 32 skills (one-line each)

**默认路由 26 个**
`sm-master`(7 模式总控) · `sm-autopilot`(自动路由) · `sm-thesis`(命题构建) · `sm-industry-map`(行业框架) · `sm-company-deepdive`(公司深度) · `sm-valuation`(估值 + 同业对比) · `sm-earnings-preview`(财报前瞻) · `sm-model-check`(模型审阅) · `sm-consensus-watch`(预期差) · `sm-industry-database`(产业 / 公司数据库) · `sm-catalyst-monitor`(事件跟踪) · `sm-roadshow-questions`(路演问题) · `sm-red-team`(反方审视) · `sm-pm-brief`(PM 一页纸) · `sm-briefing`(晨会晚报) · `sm-tape-review`(盘面 + 技术面复盘) · `sm-quant-tape`(量化看盘 · 缠论结构) · `sm-deck-builder`(PPT 生成) · `sm-batch-refresh`(批量刷新) · `sm-batch-earnings`(财报季批量) · `sm-catalyst-sweep`(催化剂扫描) · `sm-stock-screen`(选股筛标的) · `sm-hourly-watch`(小时级盯盘) · `sm-close-recap`(收盘复盘) · `sm-supervisor`(三方任务组监工) · `sm-learn`(自主学习归纳)

**v0.9 Librarian 模式 6 个（opt-in，需用户明示）**
`sm-wiki-build`(建 14 段 wiki) · `sm-daily-feed`(7 桶日刷) · `sm-question-list`(会前 vault 扫描) · `sm-health-check`(双层健康检查 + 跨源仲裁) · `sm-qa-archive`(会后归档 + 双链级联) · `sm-people-watch`(关键人物 / 社区信号流)

## Boot protocol (新会话/compact 后)

1. 读 `.task-pulse`（如存在）
2. 读 `CLAUDE.md`
3. 如 .task-pulse 有 in_progress 任务 → 主动告知用户 + 等选择，不要默认从头开始
4. 用户选了某 skill 才加载 SKILL.md
5. SKILL 内按需加载 core/preamble.md 等

⛔ **置顶要求来源**：任何任务先扫描用户本地已有资料（手稿 / 规范 / 模板 / 归档，preamble Step 2.0）——本地规范 > harness 默认 > 外部惯例，本地已有研究是工作起点。

## 三层加载（节省 token）

- **Tier 0** (always): _boot.md + .task-pulse + CLAUDE.md ≈ 1.5k
- **Tier 1** (on skill invoke): SKILL.md + preamble + postamble + adapters ≈ 6k
- **Tier 2** (on demand): evidence / compliance / output-archive / acceptance ≈ 5k

⛔ 不要在不需要时加载 Tier 2。

## Resume protocol (断点续跑)

```
1. 读 .task-pulse → 找 in_progress 任务 id
2. 读 .checkpoint/{task-id}.md → 知道做到哪段
3. 加载对应 SKILL.md
4. 从断点继续，不重复
5. 完成后写最终输出到归档路径，更新 .task-pulse 标 done
```

## Output discipline (v0.5.1 双输出)

- 输出**必须**同时**贴到对话**和**写入文件**（按 output-archive.md）
- 对话里贴完整内容（人类读），文件里存完整内容（归档 + 跨 skill 引用）
- 结尾追加 `📁 已归档：{path}` 提示 + 关键统计 + 下一步建议
- **不要**只回摘要——很多人在云端跑，打不开本地文件
- 例外：用户明确说"省 token 模式"才退回到摘要

## User customization (v0.7 新增)

**开始常规路由前**必须检查用户工作区是否有自定义：
- `{workspace}/user-templates/*.md` — 用户任务模板（日报 / 周报 / 月报等）
- `{workspace}/user-skills/*/SKILL.md` — 用户自定义 skill（L2 继承 / L3 自创）

命中 → 用用户定制，不用默认 sm-* 路由。
详见 core/user-templates.md + core/user-skills.md。

## Where to find more

| 需要时读 | 文件 |
|---|---|
| 完整 6 步开始前 | core/preamble.md |
| 完整 8 步结束后 | core/postamble.md |
| 数据源决策树 | core/adapters.md |
| 证据分级（完整中文） | core/evidence.md |
| 合规边界 | core/compliance.md |
| 归档命名规范 | core/output-archive.md |
| 验收清单 | core/acceptance.md |
| 入口菜单 | core/menu.md |
| 市场识别 | core/markets.md |
| 任务持久化格式 | core/task-pulse.md |
| 断点续跑细节 | core/checkpoint.md |
| 用户任务模板 (L1) | core/user-templates.md |
| 用户自定义 skill (L2+L3) | core/user-skills.md |
| **壁垒 / 空间 / 量价拆分框架 (v0.9.5)** | **core/moat-analysis.md** |
| **财务指标分析手册 (v0.9.5)** | **core/financial-metrics.md** |
| **三方任务组协议 (v0.9.6)** | **core/supervisor.md** |
| **自主学习协议 (v0.9.7)** | **core/learning.md** |
| **Librarian 模式总览 (v0.9)** | **core/librarian.md** |
| 14 段 wiki 标准结构 | core/wiki-architecture.md |
| 7 桶 daily feed | core/daily-feed.md |
| Q&A 双链 | core/qa-double-link.md |
| 双层健康检查 + 跨源仲裁 | core/health-check.md |
| 全链路 QC 五层 | core/full-qc.md |
