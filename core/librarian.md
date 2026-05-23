# Librarian 升级：从记忆系统到主动投研助手

> v0.7.0 新增。本文件是 Librarian 模式的总览。每一节都对应一个独立的 core/*.md 详规和一个 sm-* skill。

## 一句话

**好的投研系统不只是帮你记住了什么，而是在你需要之前就把信息拼好了、验证好了、分类好了。你要做的只是判断。**

## 上篇的位置（架构基础）

| 组件 | 角色 | 说明 |
|---|---|---|
| Obsidian | 持久化知识库（vault） | 所有研究材料以 markdown 形式落盘 |
| NotebookLM (NLM) | 跨源检索 | Google 的多文档问答工具 |
| Librarian | vault 打理 | 自己写的 Python 脚本，维护 vault |

架构本身没问题。但真正的能力边界比上篇预想得远得多——一家公司的信息可能散布在十几种来源里（管理层纪要、电话会、行业深度、券商研报、模型、公众号）。**传统做法**是需要时靠记忆或临时搜索拼起来——**拼不完整是常态，拼错是风险**。

**Librarian 升级**做的事是：**自动扫描 vault 里所有提及该公司的文件，按来源分类、按时间排序、按主题聚合，在你需要之前就把跨源综合做完了**。

打开任何一家 focus list 公司的 wiki 页面，你看到的不是某一篇文章的摘要，而是**过去 90 天所有相关材料交叉验证后的完整画面**。

## 五大能力（v0.7.0 升级核心）

| 能力 | 详规 | 配套 skill |
|---|---|---|
| 1. 每日信息流（Daily Feed）：活的公司主页 | [wiki-architecture.md](wiki-architecture.md) + [daily-feed.md](daily-feed.md) | `sm-daily-feed`、`sm-wiki-build` |
| 2. analyst-level 任务跟踪：Question List + vault 扫描 | [qa-double-link.md](qa-double-link.md) | `sm-question-list` |
| 3. Q&A 双链复利 | [qa-double-link.md](qa-double-link.md) | `sm-qa-archive` |
| 4. 健康检查与跨源仲裁：让 wiki 自己维护自己 | [health-check.md](health-check.md) | `sm-health-check` |
| 5. 全链路 QC：一致性是过程的产物 | [full-qc.md](full-qc.md) | 嵌在所有 skill 里，不是独立步骤 |

## 整体形态

```
原始材料（纪要/研报/公告/公众号/模型/新闻）
            │
            ▼
       vault（Obsidian）
            │  librarian 扫描 + 分类 + 时序聚合
            ▼
       wiki page（14 段标准结构）  ←──┐
            │                          │ wiki 级联更新
            ▼                          │
       daily feed（7 桶活页）          │
            │                          │
        分析师会议                      │
            │                          │
       question list + vault 扫描       │
            │                          │
         Q&A 双链                       │
            └──────────────────────────┘
                跨源仲裁 + 健康检查 + 全链路 QC（每天自动跑）
```

## 哲学

- **被动记忆 → 主动整理**：wiki 不是被动归档的笔记，而是在主动维护一份"当前最可信的事实集合"。
- **判断和苦活分离**：机器干的——穷举扫描、规则仲裁、写 diff 日志；人留的——判断哪个来源在当前 context 下更可信、哪个 gap 背后藏着 alpha。
- **复利是真实可观测的**：每次研究活动都在强化下一次的起点。三个季度下来，一家公司的 wiki page 不再是"材料汇总"，而是经过反复交叉验证、带完整研究脉络的知识资产。
- **QC 嵌在过程里，不是事后修补**：到出 IC Memo 或做 PPT 的时候，数据已经是验证过的，来源已经是标注过的，前后一致性已经是保证过的。最终输出物的质量是过程的自然结果。

## 何时介入（opt-in）

Librarian 升级**不会自动启用**——它需要用户的 vault 已经按 Obsidian 形态组织好。仅当用户明示以下情形时才进入 Librarian 流程：

- 用户说"建 coverage"、"起 wiki page"、"刷 daily feed"
- 用户说"见分析师前过一遍 question list"、"会后归档 Q&A"
- 用户说"跑健康检查"、"扫跨源矛盾"
- 用户说"按 Librarian 流程跑"

未明示则按原有 17 个 sm-* skill 的规则工作（参见 [_boot.md](_boot.md)）。

## 相关 core 文档

- [wiki-architecture.md](wiki-architecture.md) — 14 段 wiki page 标准结构
- [daily-feed.md](daily-feed.md) — 7 桶 daily feed 聚合规则
- [qa-double-link.md](qa-double-link.md) — Question List + Q&A 双链机制
- [health-check.md](health-check.md) — 双层健康检查 + 跨源仲裁
- [full-qc.md](full-qc.md) — 全链路 QC 五层
- [evidence.md](evidence.md) — 信源置信度 A/B 级（与跨源仲裁对齐）
