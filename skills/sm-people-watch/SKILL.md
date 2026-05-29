---
name: sm-people-watch
description: 关键人物 / KOL / 社区跟踪 skill。用于追踪 X、Reddit、Substack、播客和分析师群体里的关键发言者，记录其覆盖主题、可信度、历史命中率和最近 24 小时的重要观点变化，并把和股票池相关的信号结构化归档。
inputs:
  - 人物清单 / 账号清单 / subreddit 清单
  - 跟踪主题（如 AI 硬件 / 光模块 / GPU / 服务器）
  - 可选：关联股票池
  - 可选：时间窗（默认过去 24 小时 / 7 天）
outputs:
  - 人物追踪日报 / 周报
  - 重点发言摘录、逻辑拆解与影响映射
  - 人物索引更新建议
data_sources:
  - 见 ../../core/adapters.md
  - people-watch.md / ../../setup/workspace/people-watch.md.template
  - 公开网页 / 平台公开帖子 / 用户本地资料
markets: [GLOBAL]
trigger: 用户明示"关键人物追踪 / 跟踪 X 博主 / 跟踪 Reddit / 跟踪 KOL / 人物 watch"
---

# SM People Watch

这个 skill 不是为了把社交媒体当事实来源，而是为了把**值得持续看的信号源**结构化管理起来。

## 强制流程（v0.2 硬约束）

> ⛔ **任何分析输出之前**，必须严格执行 [`../../core/preamble.md`](../../core/preamble.md) 的 6 步开始前流程
>
> ⛔ **任何输出完成之前**，必须严格执行 [`../../core/postamble.md`](../../core/postamble.md) 的 8 步结束后流程
>
> 输出归档按 [`../../core/output-archive.md`](../../core/output-archive.md) 命名规范
> 输出验收按 [`../../core/acceptance.md`](../../core/acceptance.md) 清单逐条自检

People Watch 特别注意：

- **人物发言不是事实本身**，默认只算线索或观点
- **只有和股票池 / 主题直接相关**的发言才进重点摘要
- **必须做可信度分层**：谁是信息源、谁是二手搬运、谁是情绪噪音
- **优先讲清楚核心逻辑和边际变化**，不是简单抄一句原话

## 适用场景

- "我有一批 X 上的科技博主，帮我持续跟"
- "Reddit 哪些版块今天对 AI 供应链讨论升温了"
- "哪些关键人物最近观点变了"
- "把人、平台、主题和股票池挂起来"

## 默认起始名单（v0.2 新增）

如果工作区已经有 `people-watch.md`，优先复用用户自己的名单。

如果没有，默认从 [`../../setup/workspace/people-watch.md.template`](../../setup/workspace/people-watch.md.template) 的 starter list 起步，至少覆盖三层对象：

1. **产业逻辑锚**：如 `SemiAnalysis` / `Dylan Patel`
2. **高频信息流 / 超级散户**：如 `Jukan` / `Serenity`
3. **社区温度计**：如 `r/wallstreetbets` / `r/smallstreetbets` / `r/Semiconductors`

如果用户明确点名要补某个对象（例如 `C-Tronic`），但当前名单没有 exact handle，先在 `people-watch.md` 的待核对区登记，再继续扫描。

## 模糊搜索规则（v0.3 新增）

用户不需要每次都提供 exact handle。以下说法都应默认路由到 `sm-people-watch`：

- `关键人物观点`
- `X 观点`
- `外网观点`
- `外网怎么说`
- `海外社区怎么看`
- `推特观点`
- `Reddit 观点`
- `外网情绪`

执行时按下面顺序做模糊搜索：

1. **先按主题找**
   - 例如 `光模块 / CPO / HBM / GPU / AI infra / 数据中心电源`
2. **再按内置名单和用户名单映射**
   - 看这些主题对应哪些默认对象
3. **最后再做名字模糊匹配**
   - 如 `Ju Kan` → `Jukan`
   - `Semi` → `SemiAnalysis / SemiVision`
   - `C-Tronic` → 先查待核对区，再做近似匹配

如果名字不精确但主题明确，优先按主题抓；不要因为没有 exact handle 就停住。

## 跟踪框架

### 第一层：人物 / 社区建档

每个对象至少记录：

- 名称 / 账号
- 平台（X / Reddit / Substack / Podcast / Blog）
- 关注主题
- 关联股票 / 子赛道
- 可信度级别：A（长期稳定一手）/ B（有用但需交叉验证）/ C（情绪 / 搬运）
- 历史命中特点：催化快 / 行业视角强 / 技术视角强 / 噪音高

### 第二层：时间窗扫描

- 过去 24 小时：适合日常追踪
- 过去 7 天：适合周度复盘
- 重大事件窗：如财报周 / 展会 / 政策日

### 第三层：只提取四类信号

1. **新事实线索**：例如产能、订单、价格、客户验证线索
2. **观点明显转向**：从 bullish 变 cautious，或反过来
3. **多位关键人物共振**：不同来源指向同一主题
4. **和股票池直接相关的讨论升温**

### 第四层：优先提炼逻辑，不是摘录原话

每条重点发言都尽量拆成四段：

1. **他说了什么**
2. **背后的逻辑是什么**
3. **和昨天 / 上周相比哪里变了**
4. **这条逻辑影响哪个股票 / 子赛道，以及该怎么验证**

## 输出格式

```markdown
# People Watch · {YYYY-MM-DD}

## 今日重点人物

| 人物/社区 | 平台 | 类型 | 今日变化 | 核心逻辑 | 关联股票 | 可信度 |
|---|---|---|---|---|---|---|
| ... | ... | 产业号 / 超级散户 / 社区 | ... | ... | ... | A/B/C |

## 重点发言与逻辑

- @{account}｜{一句话摘要}
  逻辑：{订单 / capex / 价格 / 技术路线 / 情绪扩散}
  边际变化：{相对昨天 / 上周变了什么}
  影响：{ticker / 主题}
  证据等级：{公开事实 / 市场共识 / 待核验假设}
- r/{subreddit}｜{讨论升温主题}
  逻辑：{为什么突然升温}
  影响：{ticker / 主题}
  证据等级：待核验假设

## 观点变化

- {人物}：从 {旧观点} → {新观点}
- 原因：{哪条帖子 / 哪段播客 / 哪篇文章}
- 触发点：{是基本面、技术路线、产业链、还是零售情绪变化}

## 名单更新

- 新增：{为什么新进名单}
- 降级：{为什么从 A/B/C 下调}
- 待核对：{例如 C-Tronic 等还没有 exact handle 的对象}

## 需要人工跟进

- 把 {线索} 交叉验证到公告 / 公司口径 / 产业数据
- 对 {股票} 调 `sm-catalyst-monitor` / `sm-thesis`
```

## 归档方式

建议同步维护两类文件：

1. `people-watch.md`：长期人物索引
2. `monitoring/people-watch/{YYYY-MM-DD}.md`：每日或每周变化

## 约束

- ❌ 不把社交媒体观点直接当结论
- ❌ 不把匿名爆料当高置信事实
- ❌ 不做八卦式摘录
- ❌ 不把零售情绪热度包装成产业事实
- ✅ 每条信号都要落到"影响哪个主题 / 哪只股票"
- ✅ 必须给可信度分层
- ✅ 必须指出哪些需要进一步公开验证
- ✅ 默认优先扫内置名单 / 用户名单，而不是从零盲扫整个平台
- ✅ 重点对象尽量区分为**产业号 / 超级散户 / 社区**三类

## 输出归档路径

```
{coverage_root}/monitoring/people-watch/{YYYY-MM-DD}.md
```

## 与其他 skill 的关系

| 关系 | 说明 |
|---|---|
| **互补** | `sm-catalyst-sweep` 扫公开催化，`sm-people-watch` 扫关键人物观点流 |
| **下游** | 高价值线索可继续调 `sm-catalyst-monitor`、`sm-thesis`、`sm-close-recap` |
| **知识库** | 人物和主题关系可反写到 `people-watch.md` / `knowledge-index.md` |
