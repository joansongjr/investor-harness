# 关键词路由表（Single Source of Truth）

> 这份文件是 32 个 sm-* skill 的关键词触发对照。**ONBOARDING.md 和 routes-block.template.md 都从这里同步**。
> 修改时只改这里，再手动同步到其他文件。

## 触发原则

- 用户在对话里说出**任一关键词** → AI agent 自动加载对应 skill（按 `core/_boot.md` 三层加载规则）
- 关键词大小写不敏感，中英文混用
- 一句话命中多个关键词 → 走最具体的（深度 > 点评 > 速递）
- 完全无关键词命中 → 走 `sm-autopilot` 自动路由

---

## 默认路由（26 个）

### Entry / 入口

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `看看 X` / `X 怎么样` / `帮我看下 X` | `sm-autopilot` | 模糊请求自动路由 |
| `master 模式` / `总控` / `全套跑一遍 X` | `sm-master` | 7 模式长形态总控 |

### Framing / 命题与框架

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `X 投资命题` / `做 X 的 thesis` / `X 投资逻辑` | `sm-thesis` | 命题构建 |
| `X 行业框架` / `X 产业链地图` / `X 行业全景` | `sm-industry-map` | 行业框架 + 产业链 |

### Research / 单点研究

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `X 深度报告` / `深度看 X` / `起 X 的 coverage` | `sm-company-deepdive` | 公司深度（§0 结论前置 + 11 段底稿，业务线逐条展开为主；说"带量价拆分"才做完整测算）|
| `X 财报前瞻` / `X earnings preview` / `X 业绩前瞻` | `sm-earnings-preview` | 财报前瞻 |
| `审 X 的模型` / `X 模型 sanity check` / `X 模型审阅` | `sm-model-check` | 财务模型审阅 |
| `X 预期差` / `X consensus` / `X 一致预期` | `sm-consensus-watch` | 一致预期 + 预期差 |
| `数据库` / `产业数据库` / `公司数据库` / `数据底表` / `指标库` | `sm-industry-database` | 产业 / 公司数据库搭建 |
| `X 估值` / `X 贵不贵` / `X 怎么估` / `X 同业估值对比` | `sm-valuation` | 估值方法选择 + 测算 + 同业对比（v0.9.5）|

### Monitoring / 跟踪

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `X 催化剂` / `X catalyst` / `X 事件跟踪` | `sm-catalyst-monitor` | 事件 / 政策 / 订单跟踪 |
| `怎么问 X 管理层` / `X 调研提纲` / `X 路演问题` | `sm-roadshow-questions` | 路演 / 调研问题设计 |
| `盯盘` / `看盘` / `每小时看一下 X` / `X 盘中异动` | `sm-hourly-watch` | 股票池小时级盯盘 / 异动告警 |
| `收盘后复盘` / `股票池复盘` / `今天为什么涨跌` / `盘后复盘` | `sm-close-recap` | 股票池收盘归因 / 原因变化 |

### Challenge / 反方

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `反过来想 X` / `X 空头逻辑` / `X red team` / `X 反方` | `sm-red-team` | 反方审视 |

### Discovery / 选股与发现

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `选股` / `筛标的` / `挖标的` / `AI 链里还缺什么` / `涨得少的 AI 板块` | `sm-stock-screen` | 主题挖掘 / 低涨幅补涨 / 预期差选股 |

### Output / 输出

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `给 PM 一页纸` / `X 的 PM brief` / `IC 一页纸` | `sm-pm-brief` | PM / IC 一页纸 |
| `晨会` / `晚报` / `整理今天的 X` / `路演摘要` | `sm-briefing` | 晨会 / 晚报 / 纪要整理 |

### Technical / 技术面（v0.5）

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `看 X 的 K 线` / `复盘 X` / `X 盘面` / `X 技术面` | `sm-tape-review` | 盘面 + 技术面复盘 |
| `量化看盘` / `X 缠论` / `X 的缠论结构` / `X 买卖点` / `X 中枢` / `X 背驰` | `sm-quant-tape` | 量化看盘 · 缠论结构标注（v0.9.5）|

### Supervision / 三方任务组（v0.9.6）

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `监工 X` / `盯着 X 的任务` / `做 X 的监督` / `开个监工` / `三方任务组` / `语音监工` / `开实时语音监督` / `边做边监督` | `sm-supervisor` | 第二会话监督 worker；实时语音负责进度问答、分级干预、用户口令转写与收尾验收 |

### Learning / 自主学习（v0.9.7）

> **sm-learn 主要靠自动触发**（postamble 每 3-5 次会话自动跑一轮，不需要用户说任何话）。以下关键词只用于手动操作。

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `归纳提问` / `学习一下我的问法` / `跑 sm-learn` | `sm-learn` | 手动强制归纳一轮 |
| `把这些问题学进去：…` | `sm-learn`（mentor 导入） | 老师 / 资深分析师问题清单高权威导入 |
| `看看学了什么` / `看提案` / `看观察池` | `sm-learn`（审计） | 已学规则 / 待裁决提案 / 观察池查询 |
| `撤销 L-xxx` / `恢复 L-xxx` / `重建 learned-rules` | `sm-learn`（台账操作） | 规则回滚 / 复活 / 载体重建 |

### Presentation / PPT 输出（v0.8）

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `做 X 的 deck` / `X 的 IC pitch PPT` / `X 路演 PPT` / `X 客户 pitch` | `sm-deck-builder` | PPT 生成（10 段 IC / 6 段 roadshow / 8 段 earnings / 5 段 monthly / 15 段 client）|

### Batch / 批量（v0.3）

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `刷新覆盖池` / `批量过 X 列表` / `coverage refresh` | `sm-batch-refresh` | 批量行情 / 财务 / 股东 / 催化 |
| `财报季批量` / `批量前瞻` / `batch earnings` | `sm-batch-earnings` | 财报季批量前瞻 / 复盘 |
| `扫事件` / `今天有什么催化` / `catalyst sweep` | `sm-catalyst-sweep` | 覆盖池每日 / 每周催化剂扫描 |

---

## 🆕 Librarian 模式（v0.9+ · opt-in）

> **关键**：以下 6 个 skill **不在 sm-autopilot 默认路由内**，必须用户明示对应关键词才启用。
> 原因：Librarian 模式要求用户的 vault 已经按 Obsidian 形态组织好，不适合所有人。

| 关键词 | 触发 skill | 用途 |
|---|---|---|
| `起 X 的 wiki page` / `建 X 的 coverage` / `onboard X` | `sm-wiki-build` | 新建 coverage → 14 段 wiki 自动构建 |
| `刷 daily feed` / `跑每日扫描` / `今天看一下覆盖池` | `sm-daily-feed` | 每天扫 vault → 7 桶刷新 wiki §4 |
| `见 X 前过一遍 question list` / `准备 X 调研提纲` / `会前 briefing` | `sm-question-list` | question list + vault 扫描结论 |
| `跑健康检查` / `扫跨源矛盾` / `wiki 自检` | `sm-health-check` | 双层健康检查 + 跨源仲裁 |
| `会后归档` / `整理 X 的 Q&A` / `见完 X 后整理` | `sm-qa-archive` | Q&A 归档 + wiki 级联更新 |
| `关键人物追踪` / `关键人物观点` / `X观点` / `X 观点` / `外网观点` / `外网怎么说` / `海外社区怎么看` / `推特观点` / `Reddit 观点` / `外网情绪` / `跟踪 X 博主` / `跟踪 Reddit` / `人物 watch` | `sm-people-watch` | 关键人物 / 社区信号流跟踪 |

---

## 推荐工作流（多 skill 串联）

| 工作流 | 关键词 | 串联顺序 |
|---|---|---|
| 新公司 onboarding | `onboard X / 起 X 的 coverage` | `sm-wiki-build` → `sm-health-check` → `sm-thesis` |
| 日常 Librarian loop | `刷今天的覆盖池` | `sm-daily-feed` → `sm-health-check` |
| 会前准备 | `准备见 X` | `sm-question-list` |
| 会后整理 | `见完 X 整理` | `sm-qa-archive` → `sm-health-check` |
| 盘中盯盘 | `盯一下我的股票池` | `sm-hourly-watch` → `sm-catalyst-monitor` |
| 收盘复盘 | `复盘今天的股票池` | `sm-close-recap` → `sm-tape-review` |
| 主题选股 | `帮我筛 AI 链补涨标的` | `sm-stock-screen` → `sm-thesis` |
| 人物信号流 | `跟一下 X 和 Reddit 上的关键人物` / `抓一下外网观点` / `看看关键人物观点` | `sm-people-watch` → `sm-catalyst-monitor` |
| 加仓决策 | `X 要不要加仓` | `sm-thesis` → `sm-red-team` → `sm-tape-review` → `sm-pm-brief` |
| 估值重检 | `X 贵不贵 / 重新估一下 X` | `sm-company-deepdive` → `sm-valuation` → `sm-red-team` |
| 受监督深度 | `深度看 X，另开一个实时语音监工` | 任务 A：`sm-company-deepdive` ∥ 任务 B：`sm-supervisor`（并行，走 `.supervision/` 双向 mailbox）|
| 结构择时 | `X 走到哪一段了 / 找 X 的买卖点` | `sm-thesis` → `sm-quant-tape` → `sm-tape-review` → `sm-pm-brief` |
| IC pitch 全套 | `给 IC 做 X 的 pitch` | `sm-thesis` → `sm-company-deepdive` → `sm-consensus-watch` → `sm-red-team` → `sm-deck-builder` |
| 财报季全套 | `X 财报季全套` | `sm-earnings-preview` → `sm-consensus-watch` → `sm-model-check` → `sm-pm-brief` |
| 日常晨会路由 | `晨会` | `sm-catalyst-sweep` → `sm-briefing` |

---

## 硬约束

无论走哪个路由，所有 sm-* skill 都强制：

0. **⛔ 置顶：本地资料优先**——外部取数前先扫描用户本地已有资料（手稿 / 规范 / 模板 / 归档，preamble Step 2.0）；用户本地规范是最高优先级要求来源，高于 harness 默认方法论
1. 开始前：[`core/preamble.md`](../core/preamble.md) 6 步流程
2. 输出时：[`core/evidence.md`](../core/evidence.md) 证据分级（公开事实 / 财报披露 / 市场共识 / 合理推演 / 待核验假设）
3. 结束后：[`core/postamble.md`](../core/postamble.md) 8 步流程
4. 归档：[`core/output-archive.md`](../core/output-archive.md) 命名规范
5. 验收：[`core/acceptance.md`](../core/acceptance.md) 清单

⛔ 用户的任何自定义关键词 / 路由 **都不能绕过**上述约束。
