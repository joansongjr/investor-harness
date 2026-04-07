# Postamble · 强制结束后流程

> 所有 sm-* skill 在产生分析输出**之后**，必须按本文件依序完成 7 个步骤。
> 跳过任何一步视为未完成任务。
>
> 这是治"幻觉"和"不成体系"的核心机制。
>
> v0.4 改动：新增 Step 0（增量 checkpoint 写入）+ Step 7（context echo 简化），原 6 步保留。

---

## Step 0 · 增量 Checkpoint 写入（v0.4 新增 · 治健忘）

**每完成一段输出，立即更新 checkpoint，不要等任务全部完成**。

具体操作：

1. 写入 `.checkpoint/{task-id}.md` 的对应段落
2. 更新 `.task-pulse` 的 `step` 字段（如 "5/9" → "6/9"）
3. 估算剩余 context budget：
   - 剩余 > 30k → 继续下一段
   - 剩余 < 30k → 写完当前段后**主动提醒**用户"context 紧张，建议本任务跑完后开新会话"
   - 剩余 < 10k → **强制停止**，写 checkpoint，告知用户"已保存进度，请用'继续 {task-id}' 开新会话续跑"

详细机制见 [checkpoint.md](checkpoint.md)。

---

## Step 1 · 自检证据等级（治幻觉）

回看本次输出的每一段。每一条"事实陈述"必须有 F1/F2/M1/C1/H1 标签之一：

| 标签 | 含义 |
|---|---|
| **F1** | 公开事实，可直接验证 |
| **F2** | 财报 / 公告 / 权威披露 |
| **M1** | 市场观点 / 一致预期 |
| **C1** | 基于事实的合理推演（必须说明推演链路） |
| **H1** | 待核验线索或假设 |

**自检规则**：
- 没有标签的"事实"句子 → **必须**补标
- 关键结论必须有 F1 / F2 支撑
- M1 不能当事实
- C1 必须附推演链路
- H1 不能成为最终结论的唯一依据

详见 [evidence.md](evidence.md)。

---

## Step 2 · 输出"仍需补的资料"段（治幻觉的强制承认）

每份交付**必须**有这一段，按以下结构：

```markdown
## 仍需补的资料

**必需**（关键缺口，影响结论可靠性）：
- {数据 1} — 应从 {来源} 获取
- {数据 2} — 应从 {来源} 获取

**建议**（提升分析质量）：
- {数据 3}
- {数据 4}

**不确定但影响判断**：
- {假设性问题}
```

**这一段不能为空**。任何 skill 跑完都会有"我没拿到的数据"，你必须老实列出来。

如果你觉得"什么都拿到了"——说明你没真的检视过自己的输出，回去再看一遍。

---

## Step 3 · 输出合规声明

每份交付末尾**必须**附以下段落（按场景调整）：

```markdown
---

⚠️ **合规声明**：本输出不构成投资建议。
- 涉及评级 / 目标价 / 盈利预测调整 → 必须经持牌分析师人工复核
- 数据来源：{本次实际使用的数据源}
- 输出时间：{YYYY-MM-DD HH:MM}
- 使用的 skill：{sm-xxx}
```

详见 [compliance.md](compliance.md)。

---

## Step 4 · 归档输出（治不成体系）

按 [output-archive.md](output-archive.md) 的命名规范，把本次输出写入归档路径：

```
{coverage_root}/{ticker}/{skill}/{YYYY-MM-DD}-{skill}.md
```

或对于行业 / 主题任务：

```
{workspace_root}/themes/{theme}/{YYYY-MM-DD}-{skill}.md
```

**为什么必须归档**：
- 半年后回看可以 diff
- 团队成员可以 review
- 跨 skill 引用可以读到（preamble.md Step 2）
- 如果不归档，等于没做

如果用户没设置 coverage_root，归档到默认 `./output/{YYYY-MM-DD}-{skill}-{target}.md`。

---

## Step 5 · 更新任务进度（治健忘）

更新 `{workspace_root}/active-tasks.md`：

- 如果本次工作完成了某个 active task → 标记 `status: done` + 记录完成时间 + 输出归档路径
- 如果本次工作只完成了部分 → 更新 `progress` 字段，记录"做到哪一步"
- 如果本次工作产生了后续任务 → 在 `active-tasks.md` 添加新条目

格式见 [`../setup/workspace/active-tasks.md.template`](../setup/workspace/active-tasks.md.template)。

---

## Step 6 · 验收清单

按 [acceptance.md](acceptance.md) 的清单逐条自检：

- [ ] Preamble 0-5 步全部完成
- [ ] 每条事实带证据等级
- [ ] "仍需补的资料"段非空
- [ ] 合规声明已附
- [ ] 输出已归档到正确路径
- [ ] .task-pulse + active-tasks.md 已更新
- [ ] .checkpoint 已删除（任务完成时）

**任何一条没过 → 不算完成 → 必须补完再交付**。

---

## Step 7 · Context Echo Discipline（v0.4 新增 · 治不成体系 + 节省 token）

**核心原则：文件是 source of truth，对话历史不是。**

任务完成后，**不要把完整输出再贴一遍到对话上下文里**。LLM 应该只回一段简短摘要：

```
✅ 任务完成: sm-{skill} · {target}

📁 输出路径: {coverage_root}/{ticker}/{skill}/{YYYY-MM-DD}-{skill}.md
📊 文件大小: {N} KB
📑 段落数: 9/9
🏷️ 证据数: F1×{N} · F2×{N} · M1×{N} · C1×{N} · H1×{N}
🔍 仍需补的资料: {N} 项

🎯 关键发现（一句话）：
{核心结论}

⚠️ 合规：本输出不构成投资建议，需人工复核

要做什么？
- 查看完整输出 → 打开 {file path}
- 进入下一步 → 我建议跑 sm-{next-skill}
- 反方审视 → 跑 sm-red-team
```

**为什么这样设计**：

- 完整输出在文件里，永远存在
- 对话上下文只有摘要，节省 ~5-10k tokens 每任务
- context overflow / compaction 时不会丢失（文件还在）
- 用户想看完整内容随时打开文件

**不要**做以下事情：
- ❌ 把整份 9 段深度报告又贴进对话
- ❌ 把所有证据列表回显
- ❌ 把所有数据来源详细列出
- ❌ 把所有验收清单的勾选过程展示

这些都在文件里。**对话只是 control plane，不是 data plane**。

---

## 用户视角看到的最终输出（v0.4 简化版）

```
✅ 任务完成: sm-company-deepdive · 寒武纪 (688256.SH)

📁 输出路径: 覆盖公司库/688256_寒武纪/deepdive/2026-04-07-deepdive.md
📊 文件大小: 12.4 KB
📑 段落数: 9/9
🏷️ 证据数: F1×8 F2×15 M1×6 C1×9 H1×4
🔍 仍需补的资料: 5 项

🎯 关键发现：
寒武纪命题核心是思元 590 量产节奏，2026 Q2-Q3 是关键验证窗口。

⚠️ 本输出不构成投资建议。涉及评级 / 目标价需人工复核。

下一步建议：
1. sm-red-team 反方审视（推荐）
2. sm-thesis 命题构建
3. sm-pm-brief 给 PM 一页纸
```

**总成本**：~300 tokens 的对话回复 + 12 KB 的文件
**vs v0.3 旧方式**：~3000 tokens 的对话回复（输出全贴）

**节省 90%**。
