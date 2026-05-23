---
name: sm-qa-archive
description: 会后归档 skill。把 question list 转成 Q&A 存档，并触发 wiki 级联更新——新数据更新对应段落、Key Take-Away 刷新、催化剂日历加入分析师提到的时间节点、Next steps 从"还缺什么"自动生成。完整链路：问之前知道什么 → 问了什么 → 得到了什么 → 还缺什么，全部可追溯。v0.7.0 新增。
inputs:
  - vault/{ticker}/question-list-{YYYY-MM-DD}.md（sm-question-list 的产物）
  - 会议纪要 / 录音 ASR 文本 / visiting record
outputs:
  - vault/{ticker}/qa/{YYYY-MM-DD}-{event}.md
  - wiki 级联更新（§4 / §5 / §9 / §10 / §14）
  - vault/{ticker}/visiting-record-{YYYY-MM-DD}.md
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
trigger: 用户明示"会后归档 / 整理 Q&A / 见完 XX 后整理"
---

# SM QA Archive

**Librarian 模式 skill**。Q&A 双链复利的执行端。

## 强制流程

> ⛔ 先读 [`../../core/qa-double-link.md`](../../core/qa-double-link.md) 双链机制
> ⛔ 末尾按 [`../../core/postamble.md`](../../core/postamble.md)

## 五步

1. **逐题回填**：把 question list 里的每个问题对应的回答整理出来
2. **标状态**：问到了 / 没问到 / 回避了 / 和 vault 矛盾（分别处理）
3. **标置信度**：每个回答标 A 级 / B 级 + wikilink 到来源
4. **触发 wiki 级联更新**：
   - §4 Key Take-Away 🔬 桶刷新本次会议
   - §5 关键指引：管理层口径全部入库（标 B 级 + talk-book 风险）
   - §9 催化剂日历：分析师 / 管理层提到的时间节点入库
   - §10 Q&A 存档：本次问答整理后入库
   - §14 仍需补的资料：没问到 / 回避了的问题转为 Next steps
5. **diff 日志**：§13 写入本次更新涉及的段落 + 触发证据

## Q&A 存档格式

```
## Q: FY26 出海销量目标？
A: 30k 左右（管理层说"略高于 30k"）
  - 来源：[[20260520 NVDA 1Q call]] 时间戳 28:14
  - 证据等级：管理层口径（B 级，talk-book 风险）
  - 置信度：中（vs 模型 32k 差 6.7%，但管理层有保守倾向）
  - 状态：问到了 ✓
  - 级联更新：§5 关键指引、§9 催化剂日历、§10 Q&A 存档
```

## 验收

- [ ] 每题都有状态（不能空）
- [ ] 每个回答标 A/B 级 + wikilink
- [ ] §13 Diff Log 同步更新
- [ ] §14 Next steps 不为空（除非完美 deliver）
- [ ] 末尾合规声明
