# Task Pulse · 微型任务状态信号

> 一个 < 100 tokens 的 JSON 文件，让 LLM 在每次新会话用极小代价知道工作区当前状态。
> 类似 git 的 `.git/HEAD` —— 一个 pointer 文件维护整个工作区的"心跳"。

---

## 文件位置

```
{workspace_root}/.task-pulse
```

每个工作区一个。

---

## 文件格式（JSON）

```json
{
  "v": "0.4",
  "ts": "2026-04-07T14:30:00Z",
  "tasks": [
    {
      "id": "t-001",
      "skill": "deepdive",
      "target": "688256_寒武纪",
      "step": "6/9",
      "ckpt": ".checkpoint/t-001.md"
    },
    {
      "id": "t-002",
      "skill": "earnings",
      "target": "688981_中芯国际",
      "step": "3/7",
      "ckpt": ".checkpoint/t-002.md"
    }
  ],
  "compacted": false,
  "warn": null
}
```

## 字段说明

| 字段 | 类型 | 说明 |
|---|---|---|
| `v` | string | task-pulse 格式版本（"0.4" 起） |
| `ts` | ISO 8601 | 最后一次更新时间 |
| `tasks` | array | 进行中的任务（最多 5 个） |
| `tasks[].id` | string | 任务唯一 id（短格式 t-NNN） |
| `tasks[].skill` | string | skill 简称（按 output-archive.md 简称表） |
| `tasks[].target` | string | 标的（ticker_name 或 theme-slug） |
| `tasks[].step` | string | 进度（"6/9" 表示完成 6 段中的 9 段） |
| `tasks[].ckpt` | string | 该任务的 checkpoint 文件路径 |
| `compacted` | bool | 上次会话是否被 compact 过 |
| `warn` | string\|null | 上下文预警信息（context budget 剩余 < 30k 时设置） |

## 大小约束

- **目标**：< 500 字节
- **最大**：1 KB
- **超过 1 KB 触发清理**：archive 已完成任务，只保留 in_progress

## LLM 启动时的读取协议

1. 检查 `.task-pulse` 是否存在
   - 不存在 → 视为新工作区，跳过任务恢复
2. 解析 JSON
   - 解析失败 → 警告用户、跳过、不删除（避免数据丢失）
3. 如果 `compacted: true`
   - 主动告知用户："上次会话被 compact 过，已恢复任务状态"
4. 如果 `tasks` 非空
   - 列出所有进行中任务给用户
   - 等用户选择"继续 t-001"或"开始新任务"
5. 用户选择继续后
   - 读对应 `ckpt` 文件
   - 加载对应 skill
   - 从 step 指示的位置继续

## LLM 完成 step 时的更新协议

每完成一段（不是每完成一个任务），更新 `.task-pulse` 的对应 task：

```
更新前: "step": "5/9"
更新后: "step": "6/9"
        "ts": <当前时间>
```

并同时更新 `.checkpoint/{task-id}.md` 的内容。

## 任务完成时的清理协议

任务标 done 后：
- 从 `.task-pulse` 的 `tasks` 数组中移除该 task
- 把任务详情归档到 `active-tasks.md` 的"已完成"段
- 删除 `.checkpoint/{task-id}.md`

## 上下文预警协议

LLM 在每次输出后估算剩余 context budget。如果剩余 < 30k tokens：

1. 在 `.task-pulse` 设置 `warn: "context budget low: ~25k remaining"`
2. 在用户交互时主动告知："上下文预算紧张，建议本任务跑完后开新会话"
3. 如果剩余 < 10k tokens
   - **强制**写 checkpoint 后停止本任务
   - 告知用户："任务已保存到 .checkpoint/{id}，请开新会话用 '继续 t-id' 接续"

## 与 active-tasks.md 的关系

| 文件 | 作用 | 大小 | 何时读 |
|---|---|---|---|
| `.task-pulse` | 心跳信号 | < 1 KB | **每次新会话**必读 |
| `active-tasks.md` | 完整任务历史 | 5-50 KB | **只在需要任务详情时**读 |

`.task-pulse` 是 active-tasks.md 的"索引"。LLM 默认只读 .task-pulse，**只在用户问详情时**才读 active-tasks.md。

这是 v0.4 节省 token 的核心设计。
