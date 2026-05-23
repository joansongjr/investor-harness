# Daily Feed — 7 桶活页

> wiki page §4 Key Take-Away 的聚合规则。每天滚动自动跑。

## 为什么需要 daily feed

上篇架构里的 wiki page 是**静态的**——上次 session 更新了什么，就停在那里，直到下次有人想起来再改。升级后，每家被覆盖公司的 wiki page 变成一个**活的信息流**。

打开 wiki page **第一眼看到的不是过去新闻，而是"我们最近在做什么"**——做了哪些分析、准备了哪些会议、提出了哪些问题。这在做 IC Memo 时回答了一个关键问题："过去一个季度我们在这家公司上做了什么工作"，**不用翻 session log**。

## 7 个桶（按优先级）

每天扫描 vault 近 90 天窗口里所有提及该公司的文件，按文件名 token 和 frontmatter 分类，塞进 7 个桶：

| 优先级 | 桶 | 数据源 | 更新节奏 |
|---|---|---|---|
| 1 🔬 | **近期研究 Activity & Task** | `question-list/` / `Q&A/` / `分析稿/` / `meeting-prep/` | 每次研究动作落盘即刷新 |
| 2 | 公告 | `公告/` 目录 + frontmatter | 按事件节奏 |
| 3 | 研报 | `研报/` 目录 + frontmatter | 按事件节奏 |
| 4 | 纪要 | `纪要/` / `visiting-record/` | 按事件节奏 |
| 5 | 新闻 / 媒体 | `news/` + 媒体 token | 按事件节奏 |
| 6 | 公众号 | `wechat-articles/` + frontmatter | 按事件节奏 |
| 7 | 模型数据 diff | registry 触发 | 模型更新触发 |

## 设计哲学

> 本质上是把 librarian 当成一个每天替你跑搜索引擎的 RA——同样一组 query 一年 365 天稳定跑下来，覆盖率比靠人记得"今天该去 google 一下这家公司"要可靠得多，也避免"出差几天又因事发现重要新闻已经被淹没在信息流里"的常见失误。

**daily feed 7 桶**讲的是"最近发生了什么"——新闻、研报、纪要、公告，是动态信息流。
**前三段沉淀资产（关键指引 / Known Truth / 近期 Thesis）**讲的是"我们当前怎么看"——是静态判断锚点。

两者合起来才是完整的活 wiki：左手最新动态、右手沉淀判断；前者每天在变，后者每次变都伴随一次研究升级。

## 研究活动置顶（🔬 桶 = 优先级 1）

**研究活动置顶是刻意的**。打开 wiki page 第一眼看到的不是过去新闻，而是"我们最近在做什么"——做了哪些分析、准备了哪些会议、提出了哪些问题。

这在做 IC Memo 时回答了一个关键问题："过去一个季度我们在这家公司上做了什么工作"，**不用翻 session log**。

## 输出形态

每个桶下列 N 条目，每条带：

- 标题（wikilink 到原始文件）
- 日期
- 一句话摘要
- 来源标签（A 级 / B 级，对齐 [evidence.md](evidence.md)）

⛔ daily feed 不引用没有 wikilink 的来源。
⛔ daily feed 里的每条 1-2 句话；要展开看就点 wikilink 到原始文件。

## 相关

- [wiki-architecture.md](wiki-architecture.md) — 14 段 wiki page 中 §4 的位置
- [evidence.md](evidence.md) — A/B 级信源
- [health-check.md](health-check.md) — 每天巡查 daily feed 是否过期
