# Output Archive · 归档命名规范

> 所有 sm-* skill 的输出都要按本规范归档，不许散落在临时目录。
> 这是治"不成体系"的物理基础——没有归档协议，所有的"半年后回看"承诺都是空话。

---

## 为什么必须归档

1. **可 diff**：三个月后重跑同一个 skill，可以和上次输出做 diff
2. **可 review**：团队成员可以读到你的研究，PM 可以审计你的工作
3. **可引用**：其他 skill 可以读到同标的的历史输出（见 [preamble.md](preamble.md) Step 2）
4. **可追溯**：每次决策都能查到当时的研究底稿
5. **可批量更新**：周度刷新等批量任务依赖归档结构

---

## 默认目录结构

### 单股研究

```
{coverage_root}/
├── {ticker}_{name}/                  ← 一家公司一个目录
│   ├── INDEX.md                      ← 公司元数据 + 当前命题摘要
│   │
│   ├── thesis/                       ← sm-thesis 输出
│   │   ├── 2026-04-07-thesis.md
│   │   └── 2026-07-15-thesis-update.md
│   │
│   ├── deepdive/                     ← sm-company-deepdive 输出
│   │   ├── 2026-04-07-deepdive.md
│   │   └── 2026-08-20-deepdive-update.md
│   │
│   ├── earnings/                     ← sm-earnings-preview 输出
│   │   ├── 2026-Q1-preview.md
│   │   ├── 2026-Q1-postmortem.md
│   │   ├── 2026-Q2-preview.md
│   │   └── 2026-Q2-postmortem.md
│   │
│   ├── catalysts/                    ← sm-catalyst-monitor 输出
│   │   └── 2026-04-07-event-{name}.md
│   │
│   ├── consensus/                    ← sm-consensus-watch 输出
│   │   └── 2026-04-07-consensus.md
│   │
│   ├── red-team/                     ← sm-red-team 输出
│   │   └── 2026-04-07-redteam.md
│   │
│   ├── model/                        ← sm-model-check 输出 + 模型文件
│   │   └── 2026-04-07-modelcheck.md
│   │
│   ├── roadshow/                     ← sm-roadshow-questions 输出
│   │   └── 2026-04-07-roadshow.md
│   │
│   ├── pm-brief/                     ← sm-pm-brief 输出
│   │   └── 2026-04-07-pmbrief.md
│   │
│   ├── data/                         ← 原始数据快照（财报、公告等）
│   │   ├── 2024-annual-report.pdf
│   │   └── 2025-Q3-financials.json
│   │
│   └── notes/                        ← 路演纪要、调研、专家访谈
│       └── 2026-04-05-management-call.md
```

### 行业 / 主题研究

```
{workspace_root}/themes/
└── {theme-slug}/
    ├── INDEX.md
    ├── 2026-04-07-industry-map.md       ← sm-industry-map 输出
    ├── 2026-04-07-thesis.md             ← sm-thesis 输出
    └── members/                         ← 主题相关公司的索引（软链 / md 链接）
        ├── 寒武纪 → ../../coverage/688256_寒武纪/
        └── 海光信息 → ../../coverage/688041_海光信息/
```

### 晨会 / 简报

```
{workspace_root}/briefings/
├── 2026-04-07-morning.md             ← sm-briefing 输出
├── 2026-04-07-evening.md
└── weekly/
    └── 2026-W14.md
```

---

## 命名规范

### 文件名格式

```
{YYYY-MM-DD}-{skill-short}[-{descriptor}].md
```

| 字段 | 说明 | 示例 |
|---|---|---|
| `YYYY-MM-DD` | 必填，输出当天日期 | `2026-04-07` |
| `skill-short` | skill 的简称 | `deepdive` / `thesis` / `preview` |
| `descriptor` | 可选，区分同日多次输出 | `update` / `postmortem` / `q4-special` |

### Skill 简称对照表

| Full skill name | Short name |
|---|---|
| `sm-master` | `master` |
| `sm-autopilot` | `autopilot` |
| `sm-thesis` | `thesis` |
| `sm-industry-map` | `industry` |
| `sm-company-deepdive` | `deepdive` |
| `sm-earnings-preview` | `earnings` |
| `sm-model-check` | `modelcheck` |
| `sm-consensus-watch` | `consensus` |
| `sm-catalyst-monitor` | `catalyst` |
| `sm-roadshow-questions` | `roadshow` |
| `sm-red-team` | `redteam` |
| `sm-pm-brief` | `pmbrief` |
| `sm-briefing` | `briefing` |
| `sm-batch-refresh` | `batch-refresh` |
| `sm-batch-earnings` | `batch-earnings` |
| `sm-catalyst-sweep` | `catalyst-sweep` |

### Ticker 目录命名

```
{ticker}_{name}/
```

- `ticker` 优先用交易所代码（A 股 6 位、港股 4-5 位、美股字母）
- `name` 用公司中文名（A 股、港股）或英文名（美股）
- 例：`688256_寒武纪/`、`0700_腾讯控股/`、`NVDA_NVIDIA/`

---

## 配置：coverage_root 在哪

每个工作区的 `CLAUDE.md` 必须声明 `coverage_root` 路径。例如：

```yaml
# In CLAUDE.md
coverage_root: ../覆盖公司库
workspace_root: ./
```

如果用户没设置：
- 默认 `coverage_root: ./coverage`
- 默认 `workspace_root: ./`

skills 在归档前必须读 CLAUDE.md 拿到这两个值。

---

## INDEX.md 的作用

每个 ticker 目录下的 `INDEX.md` 是该公司的"元数据 + 命题摘要"：

```markdown
# {Ticker} {Name}

**market**: CN-A
**sector**: 半导体
**started_coverage**: 2026-01-15
**last_updated**: 2026-04-07
**current_thesis**: "AI 算力国产替代龙头，2026 思元 590 量产是关键拐点"
**conviction**: medium
**latest_outputs**:
  - thesis: thesis/2026-04-07-thesis.md
  - deepdive: deepdive/2026-04-07-deepdive.md
  - earnings: earnings/2026-Q1-preview.md
  - red-team: red-team/2026-04-07-redteam.md
**next_catalysts**:
  - 2026-05-XX 公司业绩会
  - 2026-Q2 思元 590 量产指引
**watchlist_triggers**:
  - 思元 590 量产延后 → 下修
  - BIS 进一步收紧 → 上修
```

INDEX.md 是 LLM **每次** preamble Step 2 检查的首要文件。

---

## 历史输出的引用机制

当 preamble.md Step 2 发现历史输出时，LLM 应该：

1. 读取最近一份同 skill 的输出，diff 与本次的差异
2. 读取该公司的 INDEX.md 拿到 current_thesis
3. 读取相关其他 skill 的最近一份（如果做 deepdive，读 thesis；如果做 earnings preview，读 deepdive 和 consensus）
4. 在本次输出顶部声明：`本次为更新 — 上次 deepdive 2026-01-15，上次 thesis 2026-02-20`

---

## 团队场景（v0.4 预留）

未来团队版会增加：
- `coverage_root` 区分 `team-coverage/` vs `personal-coverage/`
- 输出归档时自动加 `author` 字段
- 团队 review 工作流

当前 v0.3 只支持单人工作区。
