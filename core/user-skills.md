# User Skills · L2 + L3 用户自定义 skill

> v0.7 新增。L2 = 在现有 sm-* 基础上扩展（继承）。L3 = 完全自创新 skill。
>
> 这是"任务永久化"三层的**第二、三层**，比 L1 用户模板更深——不只是改输出，而是改分析框架本身。

---

## L1 vs L2 vs L3 · 何时用哪个

| 层 | 场景 | 例子 | 复杂度 |
|---|---|---|---|
| **L1 模板** | 重复格式化任务，分析流程不变 | 日报 / 周报 / 月报 | ⭐ |
| **L2 继承** | 现有 skill 差一小段，想补而不改原 skill | sm-company-deepdive + ESG 专项 | ⭐⭐ |
| **L3 自创** | 全新场景，17 个 sm-* 都没有 | 港股打新 / 可转债 / ETF 持仓对比 | ⭐⭐⭐ |

**选择原则**：能用 L1 解决的不用 L2，能用 L2 扩展的不用 L3。

---

## 文件位置

```
{workspace_root}/
├── user-skills/
│   ├── my-deepdive-esg/            ← L2: 继承 sm-company-deepdive
│   │   └── SKILL.md
│   ├── my-hk-ipo-analysis/         ← L3: 全新 skill
│   │   ├── SKILL.md
│   │   ├── templates/              ← skill 专用模板（可选）
│   │   │   └── ipo-checklist.md
│   │   └── references/             ← skill 专用参考（可选）
│   │       └── hkex-rules.md
│   └── my-cb-analysis/             ← L3: 可转债分析
│       └── SKILL.md
```

每个 user skill 一个子目录，**必须**包含 `SKILL.md`。

---

# L2 · 继承扩展

## 格式规范

```markdown
---
name: my-deepdive-esg
extends: sm-company-deepdive        # 必填：被继承的 sm-* skill
description: 在标准公司深度基础上增加 ESG 专项段
inputs:
  - 公司名 / 代码
  - 可选：ESG 评级数据
outputs:
  - 继承 sm-company-deepdive 的 9 段 + §9.5 ESG 专项
data_sources: 见 ../../../core/adapters.md + MSCI ESG / 中证 ESG
markets: [CN-A, HK, US]
---

# 我的公司深度（含 ESG 专项）

## 继承声明

本 skill 继承 `sm-company-deepdive` 的全部结构和流程。

**继承的**：
- 强制流程（preamble + postamble）
- 9 段输出结构（§1 公司定位 ... §9 仍需补的资料）
- 证据分级纪律
- 合规边界
- 归档协议

**修改 / 新增的**：
- 在 §8（未来三个月跟踪指标）和 §9（仍需补的资料）之间，**插入** §8.5 "ESG 专项"

## §8.5 ESG 专项（新增段）

### 环境 (E)
- 碳排放强度（tCO₂e / 万元营收）
- 可再生能源占比
- 水资源管理
- 废物处理 / 循环经济

### 社会 (S)
- 员工流失率 / 安全事件数
- 供应链审计（劳工 / 人权）
- 社区影响

### 治理 (G)
- 董事会独立性（独董占比）
- 高管薪酬与业绩挂钩比例
- 审计事务所（大小所）
- 关联交易

### ESG 对投资命题的影响

这一段是**关键**。不能只列数据，必须说：
- 这些 ESG 指标是否**支持**核心投资命题？
- 哪些 ESG 风险可能**颠覆**核心命题？
- 未来 ESG 监管趋严的情景下，公司是加分还是减分？

## 触发方式

- "用我的带 ESG 的深度看一下 X"
- "X 的深度（ESG 版）"
- "用 my-deepdive-esg 看 X"

## 约束（在继承的约束之上叠加）

- ESG 数据必须带证据等级，MSCI / 中证 / 公司自披露分别标 F2 / M1 / C1
- 不允许"漂绿"（greenwashing）式分析 — ESG 差但说"正在改善"必须明确证据
- ESG 段长度不超过 800 字，避免稀释核心分析
```

## LLM 处理 L2 skill 的流程

1. 用户说"用 my-deepdive-esg 看 X"
2. LLM 读 `user-skills/my-deepdive-esg/SKILL.md`
3. 看到 `extends: sm-company-deepdive` → 同时加载父 skill
4. **合并规则**：
   - frontmatter：子 skill 覆盖父 skill（子没写的字段继承父）
   - 流程（preamble/postamble）：**完全继承**，不能覆盖
   - 输出结构：以子 skill 的 `输出结构` 为准，但**必须**包含父 skill 的所有必需段（可以新增，不能删除）
   - 约束：叠加（父 + 子）
5. 执行时走父 skill 的标准流程，输出时用子 skill 的定制结构

---

# L3 · 全新自创 skill

## 格式规范

```markdown
---
name: my-hk-ipo-analysis
description: 港股 IPO 打新分析 skill（自创，未进入 Investor Harness 主库）
inputs:
  - 标的名称 / 代码
  - 招股书 PDF（可选）
  - 基石投资者清单
  - 保荐人信息
outputs:
  - IPO 打新决策摘要（7 段）
data_sources:
  - WebFetch https://www.hkexnews.hk/
  - cn-web-search 保荐人历史项目 / 基石背景
  - （可选）iFind HK 模块
markets: [HK]
license: MIT
author: 你的名字 / 团队
version: 0.1
---

# 港股 IPO 打新分析

## 强制流程

> ⛔ 本 skill 自创但**仍然**遵守 Investor Harness 的核心流程。
>
> 开始前：[`../../../core/preamble.md`](../../../core/preamble.md) 6 步
> 结束后：[`../../../core/postamble.md`](../../../core/postamble.md) 8 步
> 归档：按 `../../../core/output-archive.md` 命名规范
> 验收：按 `../../../core/acceptance.md` 清单

## 适用场景

- 港股 IPO 打新决策（是否参与 / 是否杠杆 / 是否暗盘出货）
- IPO 后一周的技术面跟踪

## 不适用

- ❌ A 股打新（A 股是中签制，逻辑完全不同）
- ❌ SPAC / 借壳上市
- ❌ 私募配售

## 必答问题

1. 基石投资者质量？他们历史 IPO 回报如何？
2. 保荐人历史 IPO 的首日 / 一周 / 一月表现？
3. 行业可比 PE 和本次定价对比？
4. 绿鞋机制 / 基石锁定期 / 发行结构？
5. 暗盘市场预期（如有）？
6. 行业景气度是否支持此时上市？

## 输出格式（7 段）

### §1 一句话判断
- "值得打 / 不建议 / 需要进一步信息"
- 给出建议的中签比例（如 10-30%）

### §2 基本信息
- 代码 / 名称 / 所属行业
- 发行规模 / 估值区间
- 保荐人 / 基石投资者
- 时间线

### §3 基石投资者分析
- 基石清单 + 锁定期 + 出资比例
- 基石的历史 IPO 记录
- 基石是否有关联方 / 战略意图

### §4 保荐人历史表现
- 近 2 年保荐的 IPO 列表
- 首日涨跌幅均值
- 破发率
- 一月后表现

### §5 估值与可比
- 当前定价的 PE / PB / PS
- 同行业港股可比（至少 3 家）
- A/H 折溢价（如适用）

### §6 风险与打新策略
- 最大下行风险
- 最可能的首日区间
- 建议策略：
  - 不打
  - 现金打
  - 杠杆打（具体杠杆倍数）
- 暗盘出货 vs 首日出货 vs 持有 3 月

### §7 仍需补的资料
- 必需
- 建议
- 不确定

## 约束

- 所有"首日涨跌"、"暗盘预期"类判断必须标 H1（待验证）
- 不给"必中"、"必破发"等武断表述
- 涉及"建议杠杆 N 倍"必须带"需人工复核"标注
- 港股通规则（如适用）必须显式说明

## 触发方式

- "帮我看一下港股 {X} 的打新"
- "{X} 值不值得打"
- "用 my-hk-ipo-analysis 看 {X}"

## 归档路径

```
{workspace_root}/coverage/HK-IPO/{ticker}_{name}/ipo-analysis/{YYYY-MM-DD}-ipo.md
```

（注意用 `HK-IPO` 作为特殊分类目录）
```

---

## L3 skill 必须遵守的最低标准

不管你多会写 skill，以下规则**不能绕过**，否则就不是"Investor Harness skill"而是"你自己瞎写的 markdown"：

### 1. 继承强制流程
SKILL.md 必须引用 `core/preamble.md` 和 `core/postamble.md`，不能自己另起炉灶。

### 2. 证据分级必备
每条事实必须带 F1/F2/M1/C1/H1 标签，和主 skill 一样。

### 3. "仍需补的资料"段非空
最后一段必须是"仍需补的资料"，分必需 / 建议 / 不确定三档。

### 4. 合规声明
末尾必须有合规声明，不承诺收益，评级目标价需人工复核。

### 5. 归档协议
输出必须写到文件，对话 + 文件双输出，按命名规范。

### 6. 数据源声明
frontmatter 必须有 `data_sources:` 字段，说明本 skill 依赖哪些数据源。

---

## 回流到主仓库（L3 → sm-*）

如果你写的 L3 skill **通用性强**，值得让所有用户都能用，可以贡献回主仓库：

```bash
cd ~/investor-harness

# 1. 从 user-skills 复制到 skills/，加 sm- 前缀
cp -r ~/workspace/user-skills/my-hk-ipo-analysis skills/sm-hk-ipo-analysis

# 2. 更新 SKILL.md 的 name 字段
# name: my-hk-ipo-analysis → name: sm-hk-ipo-analysis

# 3. 更新引用路径（from ../../../core/ to ../../core/）

# 4. 加到 _boot.md 的 17 skills 列表 → 18 skills

# 5. 加到 manifest.yaml 的 skills 数组

# 6. 加到 README 的 skill 表格

# 7. 加到 acceptance.md 的专属验收清单

# 8. 提 PR
git checkout -b feature/sm-hk-ipo-analysis
git add skills/sm-hk-ipo-analysis core/_boot.md manifest.yaml README.md core/acceptance.md
git commit -m "feat: add sm-hk-ipo-analysis skill (contributed by {your name})"
git push origin feature/sm-hk-ipo-analysis
gh pr create
```

**回流标准**：
- ✅ 解决真实投研场景，不只是你一个人的偏好
- ✅ 通过 acceptance.md 的通用验收清单
- ✅ 至少 3 位用户测试过反馈良好
- ✅ 有示例输出 / 真实案例

回流后 sm- 前缀表示"官方承认"，L3 的 my- 前缀表示"用户自用"。

---

## LLM 处理 user-skills 的完整流程

### 启动时（Preamble 扩展）

在 `core/preamble.md` Step 1 后新增：

```
Step 1.5 · 检查 user-templates 和 user-skills

读 {workspace}/user-templates/ 的 frontmatter → 匹配触发词
读 {workspace}/user-skills/ 的 frontmatter → 匹配触发词
如命中 → 用用户的，不用默认 sm-* 路由
```

### 加载时

- L2 extends 的 skill：先加载父，再应用子的 override
- L3 自创 skill：直接加载该 SKILL.md

### 执行时

严格按该 skill 的结构（模板的输出结构 / L2 的合并结构 / L3 的独立结构）。

### 归档时

- L2：按父 skill 的归档路径（除非子 skill 明确覆盖）
- L3：按该 skill 自己声明的归档路径

---

## 硬约束（再强调一遍）

任何 user skill（L2 或 L3）**不能绕过**：

1. `core/preamble.md` 6 步
2. `core/postamble.md` 8 步
3. 证据分级
4. "仍需补的资料"段
5. 合规声明
6. Dual Output Discipline
7. `acceptance.md` 通用清单

**你可以自定义的只是**：
- 输出结构的具体段落
- 新增段（不能删除必备段）
- 触发词
- 额外硬约束

---

## 常见陷阱

### 陷阱 1：L2 删除了父 skill 的必需段
- ❌ 不能"继承 sm-company-deepdive 但去掉 §9 仍需补的资料"
- ✅ 可以"在 §8 后新增 §8.5 ESG"

### 陷阱 2：L3 试图绕过 preamble
- ❌ "我这个 skill 不需要取数，跳过 Preflight"
- ✅ 走完整流程，即使取数计划是"用户手动提供"

### 陷阱 3：L3 不引用 core/
- ❌ skill 里所有规则自己重新写一遍
- ✅ 引用 core/ 的绝对文件（`../../../core/preamble.md`），继承规则

### 陷阱 4：trigger 过于泛
- ❌ `trigger: ["投资", "分析"]`
- ✅ `trigger: ["港股打新", "IPO 分析", "新股"]`

### 陷阱 5：user-skills 和主 skill 同名
- ❌ `user-skills/sm-company-deepdive/`
- ✅ `user-skills/my-company-deepdive/` 或 `user-skills/company-deepdive-v2/`

---

## 好处总结

**L2 继承**：
- 不污染主 skill，升级 harness 时不冲突
- 你的定制随工作区走
- 升级时 update.sh 不会覆盖你的 user-skills/

**L3 自创**：
- 完全自由，可以做 17 个 sm-* 没覆盖的任何场景
- 仍然继承 Investor Harness 的纪律（preamble / postamble / 合规）
- 可以回流贡献到主库，成为 sm-*
