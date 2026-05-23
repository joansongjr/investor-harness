---
name: sm-wiki-build
description: Librarian 模式下新建 coverage 的入库 skill。把丢进 vault 的原始材料（研报/纪要/公众号/公告/模型）扫一遍，按来源分类、按时间排序、按主题聚合，触发 14 段 wiki page 自动构建。v0.7.0 新增。
inputs:
  - vault 路径（Obsidian）
  - ticker / 公司名
  - 可选：模型 registry 入口（Excel tab/row 注册表）
outputs:
  - {ticker}/wiki.md（14 段标准结构）
  - {ticker}/index.md（来源血缘索引）
  - 触发首次跨源自检报告（待 sm-health-check 接力）
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
trigger: 用户明示"建 coverage / 起 wiki page / onboard XXX"
---

# SM Wiki Build

**Librarian 模式 skill**。仅当用户明示"建 coverage / 起 wiki page / onboard XXX"时启用，不在 sm-autopilot 默认路由内。

## 强制流程

> ⛔ 先读 [`../../core/librarian.md`](../../core/librarian.md) 总览
> ⛔ 再读 [`../../core/wiki-architecture.md`](../../core/wiki-architecture.md) 14 段标准
> ⛔ 输出前按 [`../../core/postamble.md`](../../core/postamble.md) 6 步结束

## 五步

1. **扫描** vault 里所有提及该公司的文件（按文件名 token + frontmatter）
2. **分类**到 7 个桶：研究活动 / 公告 / 研报 / 纪要 / 新闻 / 公众号 / 模型
3. **抽取实体**：财务关键数（从模型 registry）、管理层口径（从纪要）、Analyst TP（从研报索引）、催化剂时间点（从公告+纪要）
4. **填 14 段**：按 [wiki-architecture.md](../../core/wiki-architecture.md) 结构，每个数字带 wikilink 到原始文件 + 证据等级
5. **触发首次自检**：调用 sm-health-check 跑一遍跨源矛盾扫描，把发现的矛盾点写进 §14 仍需补的资料

## 输出形态

- `vault/{ticker}/wiki.md` — 14 段结构（不是空壳，是从材料里抽出来的真实内容）
- `vault/{ticker}/index.md` — 来源血缘索引（每个数字 → 哪个文件哪一行）
- 对话里贴**完整 wiki 草稿**（不是摘要） + 列出"需要你确认的 N 个判断点"

## 验收

- [ ] 14 段齐全（缺的段标"待补 + 缺什么"）
- [ ] §2 / §3 数字全部带 wikilink 到原始文件
- [ ] §5 / §10 管理层口径全部标 B 级 + talk-book 风险
- [ ] §14 不为空——写明下一步需要什么
- [ ] 末尾合规声明
