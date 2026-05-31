# Strategy Refresh Playbook

> 当用户要求给 `sm-stock-screen` 补录、删除、更新外部选股 strategy 时，按本文件执行。  
> 目标是维护 registry，不是临时写一串名字。

## 1. 新 strategy 进入前，先判 4 件事

1. 它是 `generator`、`validator`、`data`，还是 `meta`
2. 它的 `vote_mode` 是 `direct`、`gate`，还是 `none`
3. 它属于哪个 `family`
4. 它的 `markets`、`timeframe`、`dependency` 是什么

## 2. 最低出处要求

每个新增 strategy 至少补这 6 个字段：

- `owner/slug`
- `display name`
- `snapshot date`
- `source type`
  - `ClawHub inspect`
  - `GitHub source`
  - `workspace list`
- `core principle`
- `external dependency`

## 3. 推荐的刷新来源

优先顺序：

1. 本地 `ClawHub_Awesome_Skills_完整清单.xlsx`
2. `npx clawhub search "<query>"`
3. `npx clawhub inspect <slug> --file SKILL.md`
4. 如是 openclaw/tree 技能，再补 GitHub 源码路径

## 4. 什么时候允许进 registry

### 直接进入

- 有明确 `SKILL.md`
- 能判断 role / family
- 原理不是纯 marketing 文案

### 只做观察，不直接纳入

- 只有营销描述，没有工作流
- 无法判断是否真在做选股
- 明显只是数据接口，不是策略
- 强依赖黑箱付费 API，且没有最小方法说明

## 5. 刷新时的更新点

更新以下 3 处：

1. `references/clawhub-quant-registry.md`
2. 如 family 有变化，更新 `references/strategy-compare-contract.md`
3. 如 trigger 或输出合同变了，再改 `SKILL.md`

## 6. 回写原则

- registry 只写**稳定信息**
- 临时结论、推荐榜、某次跑出来的共识票，不写进 registry
- registry 记录的是方法，不是某次结果
