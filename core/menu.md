# Menu · 零配置入口菜单

> 这是用户首次使用 Investor Harness 时看到的"前台菜单"。
> 当 LLM 检测到用户输入符合下列任一触发条件，**必须直接显示这个菜单**，不要先解释 harness 是什么。

---

## 触发条件

LLM 看到以下任一情况，立即显示菜单：

- 用户说 "investor harness" / "harness" / "你能做什么" / "帮帮我"
- 用户说 "菜单" / "menu" / "选项" / "怎么用"
- 用户在新会话开始时只发了一个问候（"你好" / "在吗" / "ready"）
- 用户输入完全模糊（不到 5 个字且没有任何标的、行业、动作关键词）
- 用户明确说 "显示菜单" / "show menu"
- 用户问 "能帮我做什么" / "你会什么"

---

## 菜单内容（直接复制输出）

```
🎯 Investor Harness 已就绪！请选择你想做什么：

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 研究类
1️⃣  公司深度研究 — 起 coverage 或更新跟踪
2️⃣  行业图谱 — 产业链地图、供需格局、关键公司
3️⃣  投资命题构建 — 定义核心矛盾、拆解研究问题

📈 财报类
4️⃣  财报前瞻 — 关注点、beat/miss 路径、指引听点
5️⃣  财务模型校验 — 假设审阅、敏感性分析、断裂点

🔍 跟踪类
6️⃣  一致预期监控 — 预期差挖掘、估值锚变化
7️⃣  催化剂跟踪 — 事件/政策/订单/价格驱动
8️⃣  路演问题设计 — 调研提纲、业绩会高价值问题

⚔️ 风控类
9️⃣  反方论证 (Red Team) — 挑战多头逻辑、找证伪点

📋 输出类
🔟  基金经理摘要 (PM Brief) — 一页纸决策摘要
1️⃣1️⃣ 投研简报 — 晨会纪要、收盘复盘、调研纪要

⚡ 批量类（v0.3 新增）
1️⃣2️⃣ 覆盖池批量刷新 — 行情/财务/股东/催化一次更
1️⃣3️⃣ 财报季批量前瞻 — 一周内多家财报排队前瞻
1️⃣4️⃣ 每日催化剂扫描 — 晨会前 30 分钟扫一遍覆盖池

🤖 自动模式
1️⃣5️⃣ Autopilot — 给我一个公司名/行业/事件，自动跑全流程
1️⃣6️⃣ Master 模式 — 7 种工作模式自动识别，一个 skill 搞定

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

输入编号或直接描述你的需求，例如：
• "1" 或 "帮我深度看一下宁德时代"
• "4" 或 "做中芯国际财报前瞻"
• "9" 或 "我看多 AI 算力，帮我反方论证一下"
• "帮我看一下光模块行业" → 自动进入行业图谱

───

💡 提示：你还可以设置个人投研工作区，让 Harness 更好用：
• coverage.md — 你的覆盖池（跟踪哪些股票）
• biases.md — 你的投研偏差记录（Red Team 会自动检查）
• decision-log.md — 投资决策日志（半年后回看用）
• active-tasks.md — 任务进度持久化（跨会话接续）

要现在初始化吗？输入 "初始化工作区" 即可，10 秒搞定。
```

---

## 编号到 skill 的映射

| 编号 | Skill | 说明 |
|---|---|---|
| 1 | sm-company-deepdive | 公司深度研究 |
| 2 | sm-industry-map | 行业图谱 |
| 3 | sm-thesis | 投资命题构建 |
| 4 | sm-earnings-preview | 财报前瞻 |
| 5 | sm-model-check | 财务模型校验 |
| 6 | sm-consensus-watch | 一致预期监控 |
| 7 | sm-catalyst-monitor | 催化剂跟踪 |
| 8 | sm-roadshow-questions | 路演问题设计 |
| 9 | sm-red-team | 反方论证 |
| 10 | sm-pm-brief | PM 一页纸 |
| 11 | sm-briefing | 投研简报 |
| 12 | sm-batch-refresh | 覆盖池批量刷新 |
| 13 | sm-batch-earnings | 财报季批量前瞻 |
| 14 | sm-catalyst-sweep | 每日催化剂扫描 |
| 15 | sm-autopilot | 自动路由 |
| 16 | sm-master | 全能 7 模式 |

---

## 用户输入解析规则

### Case 1：输入纯数字（"1" / "4" / "11"）

直接路由到对应 skill：
- 询问标的："好的，要分析哪家公司？" 然后等用户回答
- 拿到标的后，**立即按对应 skill 的强制流程开跑**（preamble.md → skill 主体 → postamble.md）

### Case 2：输入自然语言描述

LLM 自动识别用户意图，匹配最合适的 skill：

- 出现公司名 + "深度 / 起 coverage / 看看" → sm-company-deepdive
- 出现行业名 + "看看 / 怎么看" → sm-industry-map
- 出现 "财报 / 业绩 / 前瞻" → sm-earnings-preview
- 出现 "反方 / 唱反调 / 空头 / 找问题" → sm-red-team
- 出现 "晨会 / 简报 / 整理" → sm-briefing
- 出现 "PM / 一页纸 / 给老板" → sm-pm-brief
- 出现 "调研 / 路演 / 业绩会问题" → sm-roadshow-questions
- 出现 "模型 / 估值 / DCF" → sm-model-check
- 出现 "一致预期 / 预期差" → sm-consensus-watch
- 出现 "催化 / 事件 / 政策" → sm-catalyst-monitor
- 出现 "刷新覆盖池 / 周度更新" → sm-batch-refresh
- 出现 "财报季 / 一周财报" → sm-batch-earnings
- 出现 "扫一遍 / 今日催化" → sm-catalyst-sweep
- 完全模糊 / 没线索 → sm-autopilot

### Case 3：输入 "初始化工作区"

走零配置初始化流程（见下节）。

### Case 4：用户输入完全跟投研无关

礼貌告知 Investor Harness 的范围，再次显示菜单。

---

## 零配置初始化流程

当用户输入"初始化工作区"或类似指令时，LLM 必须按以下流程操作：

### Step 1：检查 bootstrap.sh 是否可执行

如果用户安装了完整 harness，运行：
```bash
bash ~/.claude/skills/investor-harness/setup/bootstrap.sh ./
```

如果用户没有 bash 权限或脚本不可用，**手动**创建模板文件（见下）。

### Step 2：交互填空（最少必填）

用户必须填的最少信息：
1. **你的角色** — 卖方分析师 / 买方研究员 / PM / 个人投资者 / 学习中
2. **覆盖范围** — 哪个市场 + 哪些行业（一句话）
3. **首批覆盖标的** — 至少 1 个（用来初始化 coverage.md）

```
让我帮你初始化工作区。回答 3 个问题就好：

1. 你是谁？（卖方分析师 / 买方研究员 / PM / 个人投资者 / 学习中）
2. 你覆盖什么？（一句话，例：A 股科技板块 / 美股半导体）
3. 你正在跟踪哪个标的？（至少给 1 个，可以是公司名或代码）
```

### Step 3：生成最小可用工作区

根据用户回答，**立即**生成：
- `CLAUDE.md` — 填好用户角色和覆盖范围
- `memory.md` — 填好身份和触发约定
- `coverage.md` — 填好首批标的
- `active-tasks.md` — 空模板

`biases.md` / `decision-log.md` / `watchlist.md` / `research-queue.md` 暂时不创建，等用户实际用到时再问。

### Step 4：返回菜单 + 引导第一个任务

```
✅ 工作区初始化完成！
   - 角色：{你填的}
   - 覆盖：{你填的}
   - 已添加首批标的到 coverage.md：{ticker}

要不要我现在帮你跑一次第一个任务？建议从这个开始：

🎯 用 sm-company-deepdive 起 coverage：{你填的标的}

要继续吗？（输入"继续"或选择菜单的其他选项）
```

---

## 不显示菜单的情况

LLM **不应该**显示菜单的情况：

- 用户已明确指定了 skill 和标的（"用 sm-thesis 看一下宁德时代"）
- 用户在 active-tasks.md 里有进行中任务，且新输入显然是接续原任务
- 用户在跟某个 skill 的中间步骤交互
- 用户问了一个具体问题，应该被路由而不是被菜单打断

---

## 在 CLAUDE.md 中如何引用

任何工作区的 CLAUDE.md 应在"默认行为"段加上一句：

> **Menu trigger**: 当用户输入符合 [`~/.claude/skills/investor-harness/core/menu.md`](~/.claude/skills/investor-harness/core/menu.md) 的触发条件时，必须显示该文件中的菜单内容。

这样无论是单 skill 模式（只装了 sm-master）还是完整套件模式，都能用到菜单。
