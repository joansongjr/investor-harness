---
name: sm-health-check
description: Librarian 模式下每天对 focus list 自动跑两层健康检查（状态巡查 + 跨源矛盾扫描）。让 wiki page 不退化成"信息汇总"，而保持"可信事实集合"。这是这套系统能被称为"主动投研助手"而不是"被动记忆系统"的核心理由。v0.7.0 新增。
inputs:
  - focus list（holdings + coverage）
  - vault 路径
outputs:
  - health-check-{YYYY-MM-DD}.md（状态巡查 flag 清单 + 跨源矛盾清单 + 建议追问方向 + 当日 diff 日志）
  - 每家公司 wiki §13 Diff Log 自动更新
data_sources: 见 ../../core/adapters.md
markets: [CN-A, CN-FUND, HK, US, GLOBAL]
trigger: 用户明示"跑健康检查 / 扫跨源矛盾 / wiki 自检"
schedule: 建议每天交易日盘后跑一次
---

# SM Health Check

**Librarian 模式 skill**。让 wiki 自己维护自己。

## 强制流程

> ⛔ 先读 [`../../core/health-check.md`](../../core/health-check.md) 完整规则
> ⛔ 末尾按 [`../../core/postamble.md`](../../core/postamble.md)

## 第一层：状态巡查（六项）

| # | 检查项 | 输出 |
|---|---|---|
| 1 | TP > 60 天没更新？ | flag + 距今天数 |
| 2 | 距财报 < 21 天？ | flag + 财报日 + 建议触发 sm-earnings-preview |
| 3 | 股价偏离 TP > 30%？ | flag + 偏离方向 + 历史 |
| 4 | 新研报没反映到页面？ | flag + 待入库文件清单 |
| 5 | 催化剂到期未验证？ | flag + 催化剂内容 + 应该看到什么 |
| 6 | wiki 段落 > 90 天没更新？ | flag + 段落名 + 距上次更新天数 |

## 第二层：跨源矛盾扫描

每家公司每天对比：

- 管理层指引 vs 卖方 forecast
- 新研报 TP vs 旧研报 TP
- 模型数字 vs 公众号披露的运营数据

⛔ **差异超 5% 就标记**。

## 仲裁规则（不要自动选边）

按 [health-check.md](../../core/health-check.md) 跨源仲裁：

- 同级别冲突按时间，新覆盖旧（保留 diff）
- 跨级别冲突 A 级胜，但 B 级保留作 forward-looking 参考
- 判不准的 raise 出来 ping 用户

## 输出形态

```
# Health Check {YYYY-MM-DD}

## 状态巡查
- [WARN] NVDA: TP 75 天未更新（GS 上次 04-10）
- [INFO] AVGO: 距财报 14 天，建议触发 sm-earnings-preview

## 跨源矛盾
- NVDA FY26 ASP:
  · 管理层口径 30k（[[20260315 call]], B 级）
  · 卖方推算 28k（[[20260410 GS]], B 级）
  · 自己模型 32k（A 级）
  差异 6.7%，建议会上追问下半年新客户

## 建议追问方向
- ...

## 今日 wiki diff
- NVDA §4: 新增 [[20260520 The Information]]
- AVGO §2: 模型 registry diff，FY26 EPS 上修 3%
```

## 验收

- [ ] 两层都跑（不能只跑一层）
- [ ] 每个 flag 带触发条件 + 建议下一步
- [ ] 跨源矛盾必须给百分比差异
- [ ] §13 Diff Log 同步写入每家公司 wiki
