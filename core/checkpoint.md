# Checkpoint · 任务断点续跑机制

> 让 skill 能在 context overflow / compaction / 重开会话之后**从断点继续**而不是从头开始。
> 这是 v0.4 解决"健忘"痛点的核心机制。

---

## 文件位置

```
{workspace_root}/.checkpoint/{task-id}.md
```

每个 in_progress 任务一个文件。

---

## 何时写 checkpoint

每个 sm-* skill 必须遵循以下规则：

### Rule 1：每完成一个 H2 段就写 checkpoint

不要等任务全部完成才写文件。每完成一段就更新 checkpoint。

例：sm-company-deepdive 9 段，每完成 §1、§2、§3... 都更新 checkpoint。

### Rule 2：每次取数后写 checkpoint

如果一次 iFind 调用返回了关键数据，立即写入 checkpoint，避免数据丢失。

### Rule 3：context budget 警告时强制写 checkpoint

LLM 估算到剩余 context < 30k tokens 时，必须立即：
1. 写完当前段的 checkpoint
2. 告知用户"已写入 checkpoint，建议开新会话续跑"
3. 不再继续新段

---

## Checkpoint 文件格式

```markdown
# Checkpoint · {task-id}

**task_id**: t-001
**skill**: sm-company-deepdive
**target**: 688256_寒武纪
**started**: 2026-04-07T14:00:00Z
**last_updated**: 2026-04-07T14:30:00Z
**step**: 6/9
**status**: in_progress

## Completed sections

### §1 公司定位 ✅
{完整内容，按最终输出格式}

### §2 业务拆分 ✅
{完整内容}

### §3 收入驱动 ✅
{完整内容}

### §4 利润驱动 ✅
{完整内容}

### §5 核心竞争力 / 风险点 ✅
{完整内容}

### §6 市场关注焦点 ✅
{完整内容}

## In progress

### §7 与可比公司的关键差异 (in_progress)
{已经写到的部分}

## Pending

- §7 (continue)
- §8 未来三个月跟踪指标
- §9 仍需补的资料

## Data fetched so far

| Source | Tool | Result |
|---|---|---|
| iFind | get_stock_summary | ✅ pulled |
| iFind | get_stock_financials | ✅ pulled |
| iFind | get_stock_shareholders | ✅ pulled |
| WebSearch | "寒武纪 海光 对比" | ⚠️ partial |
| - | 卖方一致预期 | ❌ pending |

## Resume instructions

下次会话用以下指令恢复：

```
继续 t-001
```

LLM 会自动：
1. 读本文件
2. 跳过已完成的 §1-§6
3. 继续 §7（从已写的部分接着）
4. 完成 §8、§9
5. 写最终输出到归档路径
6. 删除本 checkpoint
7. 更新 .task-pulse 标 done
```

---

## 如何续跑

### 用户视角

```
用户：继续 t-001
LLM: 检查 .task-pulse → 找到 t-001
LLM: 读 .checkpoint/t-001.md → 看到做到 §6
LLM: 读 sm-company-deepdive/SKILL.md
LLM: 加载 §1-§6 的内容（已完成的）
LLM: 从 §7 继续工作
LLM: 完成 §7-§9
LLM: 写最终输出到 coverage/688256_寒武纪/deepdive/2026-04-07-deepdive.md
LLM: 删除 .checkpoint/t-001.md
LLM: 更新 .task-pulse 移除 t-001
LLM: 输出摘要给用户
```

### 简化指令

用户可以用以下任一方式触发续跑：
- "继续 t-001"
- "continue t-001"
- "resume task 001"
- "接着上次的"（LLM 自动从 .task-pulse 找最近一个 in_progress 任务）

---

## Checkpoint 文件大小约束

- **典型大小**：3-10 KB（包含 6-8 段已完成内容）
- **最大**：50 KB（如果超过说明任务粒度太粗，应该拆分）
- **超过 50 KB 的应对**：
  - 把已完成的段落归档到归档路径
  - checkpoint 只保留"指针"和"剩余部分"

## 清理协议

| 状态 | 清理时机 |
|---|---|
| 任务完成 | 立即删除 checkpoint |
| 任务取消 | 立即删除 checkpoint |
| 任务超过 7 天没动 | 标记为 stale，提醒用户清理 |
| 任务超过 30 天没动 | 自动归档到 `.checkpoint/archive/`，从主目录移除 |

---

## 与 .task-pulse 的协作

```
用户开新会话
   ↓
LLM 读 .task-pulse（< 100 tokens）
   ↓
看到 t-001 in_progress, ckpt: .checkpoint/t-001.md
   ↓
用户："继续 t-001"
   ↓
LLM 读 .checkpoint/t-001.md（~5 KB）
   ↓
LLM 加载 sm-company-deepdive
   ↓
从 §7 继续
```

总成本：~3k tokens 恢复完整任务状态，vs 从头跑 ~25k+ tokens。

**节省：90%+**。

---

## 边界场景

### Q: 用户在中途改了想法，想换一个 skill 怎么办？
- 提示用户："t-001 还没做完，确定要切换吗？"
- 用户确认后，移动 checkpoint 到 `.checkpoint/abandoned/`，保留以便事后回看

### Q: 多个会话同时编辑同一个 task 怎么办？
- 用 ts 字段做"乐观锁"
- 写入前检查 ts，如果发现 ts 比自己读的新 → 拒绝写入，告知用户冲突

### Q: checkpoint 文件本身丢了怎么办？
- LLM 检测到 .task-pulse 有 task 但 ckpt 文件不存在 → 警告用户 → 提供"从头开始"或"标记 abandoned"选项

### Q: 任务没有明确 9 段结构（比如 sm-briefing）怎么 checkpoint？
- 用 logical sections（"今日事件 1 - 已完成"、"事件 2 - 进行中"）
- step 字段写 "2/3" 等

---

## 给 skill 设计者的硬约束

每个 sm-* skill 在设计时必须支持 checkpoint。必要条件：

1. **可分段**：能拆成 N 个顺序步骤，每步可独立写 checkpoint
2. **幂等**：从 checkpoint 续跑产出的最终输出和一次跑完的输出相同
3. **可追溯**：checkpoint 包含足够信息让 LLM 重建上下文

不满足这三条的 skill 设计应该重做。
