---
name: sm-daily-feed
description: Librarian 模式下每天扫 vault 生成 7 桶 daily feed，刷新每家 focus list 公司 wiki page 的 §4 Key Take-Away。让 wiki 从静态笔记变成活的信息流。v0.7.0 新增。
inputs:
  - vault 路径
  - focus list（holdings + coverage）
  - 时间窗口（默认近 90 天）
outputs:
  - 每家公司 wiki.md §4 段落刷新
  - daily-feed-{YYYY-MM-DD}.md（当日全部公司聚合摘要）
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
trigger: 用户明示"刷 daily feed / 跑每日扫描 / 今天看一下覆盖池"
schedule: 建议每天交易日盘前 + 盘后各跑一次
---

# SM Daily Feed

**Librarian 模式 skill**。把 librarian 当成每天替你跑搜索引擎的 RA——同样一组 query 一年 365 天稳定跑下来，覆盖率比靠人记得"今天该去 google 一下"要可靠得多。

## 强制流程

> ⛔ 先读 [`../../core/daily-feed.md`](../../core/daily-feed.md) 7 桶规则
> ⛔ 末尾按 [`../../core/postamble.md`](../../core/postamble.md) 收尾

## 输出（每家公司）

**§4 Key Take-Away（7 桶）**：

```
🔬 近期研究 Activity & Task
  - [[20260520 NVDA earnings prep]] — 准备 Q1 业绩前瞻 7 问
  - [[20260518 NVDA red-team]] — 反方审视 China revenue

📋 公告（近 90 天）
  - [[2026-05-15 NVDA 8-K]] — 数据中心营收指引上修

📊 研报
  - [[20260514 GS NVDA]] — TP 上调至 200

🎙 纪要
  - [[20260512 NVDA 1Q26 call]] — Jensen 提 sovereign AI 加速

📰 新闻 / 媒体
  - [[20260520 The Information]] — Hyperscaler capex commentary

📱 公众号
  - [[20260519 半导体行业观察]] — HBM4 良率突破

📈 模型数据 diff
  - [[FY26 ASP 上调 8% (registry diff @ 20260518)]]
```

## 验收

- [ ] 每个桶下条目带日期 + wikilink + 1 句话摘要 + A/B 级
- [ ] 🔬 桶置顶（不能排在公告后面）
- [ ] 空桶要明确标"近 90 天无更新"——不要省略
- [ ] 同时贴对话 + 写入文件
