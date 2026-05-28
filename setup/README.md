# Investor Harness · Setup

帮助 **B 类用户**（已有 LLM harness 但没有结构化的投研记忆和任务管理）一键建立分析师工作区。

---

## 谁需要这个

如果你符合以下任何一条，跑一次 setup：

- 你已经在用 Claude Code / Codex / OpenCode / OpenClaw，但每次问投研问题都从零开始，LLM 不记得你的覆盖池、活跃命题、已知偏差
- 你有自己的 agent 团队但角色定义混乱，每个 agent 都在做大杂烩
- 你想让 LLM 像分析师一样工作但不知道从哪开始
- 你试过用 Investor Harness skills 但发现 LLM 没记忆，每次都要重新解释你研究什么

如果你已经有完善的 memory + task 系统（例如经验丰富的 prompt engineer / 重度 Claude Code 用户），可以跳过 setup，直接读 `workspace/` 里的模板，按需挑选融入你现有系统。

---

## 一键安装

```bash
bash setup/bootstrap.sh ~/my-investor-workspace
```

会在 `~/my-investor-workspace` 创建：

```
my-investor-workspace/
├── CLAUDE.md          ← Claude Code / OpenClaw 工作区入口
├── AGENTS.md          ← Codex / OpenCode 工作区入口
├── memory.md          ← 投研记忆系统骨架
├── coverage.md        ← 覆盖公司清单
├── watchlist.md       ← 观察池（潜在覆盖）
├── knowledge-index.md ← 本地知识库总索引（capacity-style wiki 首页）
├── people-watch.md    ← 关键人物 / X / Reddit 追踪表
├── selection-pipeline.md ← 选股 pipeline / 主题筛选池
├── decision-log.md    ← 投资决策日志
├── research-queue.md  ← 待研究队列
├── biases.md          ← 自我偏差清单
├── coverage/          ← 覆盖池归档根目录（每家公司一个子目录）
├── themes/            ← 行业 / 主题归档根目录
├── briefings/         ← 晨会 / 晚报 / 周报归档目录
├── .task-pulse        ← 任务心跳（跨会话续跑）
└── .checkpoint/       ← 中断续跑 checkpoint
```

然后：
1. 在你的 harness 里把这个目录设为工作目录（Claude Code: `cd` 进去；Codex: 启动时指定）
2. 编辑 `AGENTS.md`（Codex / OpenCode）或 `CLAUDE.md`（Claude Code / OpenClaw）
3. 编辑 `coverage.md` 写入你正在覆盖的公司
4. 编辑 `memory.md` 写入你的研究身份（卖方/买方/PM/个人）
5. 开始用 `sm-autopilot` 等 skill 提问

LLM 会在每次对话开始时自动读取对应的工作区入口文件（`AGENTS.md` 或 `CLAUDE.md`）和 `memory.md`，并用 Investor Harness 的纪律来回答你。之后任何覆盖池相关任务都应自动归档到 `coverage/{ticker}_{name}/...`，不能只留在对话里。

---

## 模板说明

### `CLAUDE.md` / `AGENTS.md` — 分析师 persona

让 LLM 在所有对话中默认按"持牌证券分析师"的行为模式工作。包括：
- 默认调用哪些 Investor Harness skills
- 默认引用 `core/adapters.md` 的取数协议
- 默认按 `core/evidence.md` 标证据等级
- 默认遵守 `core/compliance.md` 的合规边界
- 不主动追问、不武断结论、不混合事实与推演

### `memory.md` — 记忆系统

LLM 启动时第一个读的文件，决定加载什么上下文。骨架包括：
- 你的研究身份（决定加载哪些 skills）
- 你的覆盖池（指向 `coverage.md`）
- 当前活跃投资命题（指向各个 thesis 文件）
- 你的已知偏差和反向检查清单（指向 `biases.md`）

### `coverage.md` — 覆盖清单

每家覆盖公司一行 + 链接到深度文档。这是你的"工作画布"，决定 LLM 在没有明确指定标的时优先想到谁。

### `watchlist.md` — 观察池

未起 coverage 但在跟踪的公司/主题。用来防止 LLM 把你的观察池和正式覆盖混在一起。

### `knowledge-index.md` — 本地知识库总索引

这是一个 markdown 版的 wiki 首页，定位上接近 Capacity / Wiki 的总入口：
- 公司入口
- 主题入口
- 人物 / 社区入口
- daily feed / 盯盘 / 收盘复盘入口
- 选股 pipeline 入口

### `people-watch.md` — 关键人物 / 社区追踪

用于维护你长期想看的：
- X / Twitter 科技博主
- Reddit 重点 subreddit
- Substack / 播客 / 行业博客
- 每个对象的主题、可信度、命中记录

### `selection-pipeline.md` — 选股流程池

用于把"我想找票"结构化，而不是直接跳进深度：
- A / B / C 三级候选池
- 这次为什么筛
- 还缺什么验证
- 常用筛法模板（瓶颈环节 / 低涨幅补涨 / 预期差 / 错杀修复 / 扩散）

### `decision-log.md` — 决策日志

每次 buy/sell/hold/skip 的决策记录。包含日期、当时的命题、当时的关键证据、当时的反方观点、未来验证节点。
**这是反向纪律的核心**——半年后回看决策日志，能识别自己的判断偏差。

### `research-queue.md` — 待研究队列

你列了"应该研究但还没研究"的清单。LLM 在你空闲时可以推荐"今天该研究什么"。

### `biases.md` — 自我偏差清单

你**已经知道**自己有哪些偏差（追涨杀跌？锚定？过度自信？...），让 LLM 在每次给结论前检查一下你是不是又犯了。

---

## 多 agent 团队（进阶）

如果你在 OpenClaw / Codex / 自定义 harness 里运行多 agent 团队，看 [agents/README.md](agents/README.md)。我们提供 5 个标准化的投研角色定义（数据员、命题员、反方、PM 视角、合规员），任何 harness 都可以适配。

---

## 关于"记忆系统"为什么重要

LLM 没有跨会话记忆。如果不通过工作区入口文件（`AGENTS.md` 或 `CLAUDE.md`）和 `memory.md` 显式加载上下文，每次新会话都是一个"失忆的初级研究员"。

设计良好的记忆系统让 LLM：
- **认得你**：你是卖方/买方/个人，研究什么行业，用哪些数据源
- **认得标的**：你正在跟踪哪些公司，每家的核心命题是什么
- **认得自己**：自己有哪些已知偏差，每次结论前检查
- **认得历史**：过去做过什么决策，结果如何，下次别再犯

这是 Investor Harness 比"装一堆 skill"更重要的设计——**记忆系统决定 LLM 是个一次性问答机器还是你的长期研究伙伴**。
