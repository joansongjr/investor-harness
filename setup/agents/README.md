# Investor Harness · Multi-Agent Roles

> 适用人群：在 OpenClaw / Codex / Claude Code 等 harness 上运行多 agent 团队，希望把投研工作流"角色化"的进阶用户。

---

## 为什么要分角色

单 agent 容易混淆三件事：

1. **取数** vs **分析** vs **决策**
2. **多头视角** vs **空头视角**
3. **研究员视角** vs **基金经理视角**

混在一起的结果：LLM 一会儿当数据员一会儿当 PM，证据等级松散，反方审视流于形式。

把这些**显式拆成不同的 agent**，每个 agent 只负责一种职责，最后由协调员汇总，结果会显著更可靠。

---

## 推荐的 5 个角色

| 角色 | 文件 | 职责 | 调用的主 skill |
|---|---|---|---|
| **Data Fetcher** | [data-fetcher.md](data-fetcher.md) | 取数员，只负责按 adapter 协议拿数据 | 直接调 MCP/搜索工具，不分析 |
| **Thesis Builder** | [thesis-builder.md](thesis-builder.md) | 命题构建，把数据收敛成可验证命题 | sm-thesis / sm-company-deepdive / sm-industry-map |
| **Red Teamer** | [red-teamer.md](red-teamer.md) | 反方，强制对命题做空头审视 | sm-red-team |
| **PM Voice** | [pm-voice.md](pm-voice.md) | 基金经理视角，决策导向 | sm-pm-brief / sm-consensus-watch |
| **Compliance Checker** | [compliance-checker.md](compliance-checker.md) | 合规审查，输出前最后一道关卡 | core/compliance.md 全量 |

---

## 协作流程

```
用户 → Coordinator
         │
         ├── Data Fetcher (取数)
         │       ↓
         ├── Thesis Builder (建命题)
         │       ↓
         ├── Red Teamer (反方审视)
         │       ↓
         ├── PM Voice (压缩为决策)
         │       ↓
         └── Compliance Checker (合规过审)
                 ↓
            汇总输出给用户
```

如果你只跑单 agent，可以让单个 agent **依次扮演**这 5 个角色，每个阶段输出一个 section，最后整合。这样虽然没有并行优势，但保留了职责拆分的纪律。

---

## 在 OpenClaw / Codex / Claude Code 里怎么用

不同 harness 的 multi-agent 配置格式不一样，但通用做法是：

1. 在你的 harness 里创建 5 个 agent，名字分别用上面的角色
2. 把对应 `agents/{role}.md` 的内容粘到每个 agent 的 system prompt
3. 配置一个 coordinator agent，它的 system prompt 是"按上面的协作流程串联"
4. coordinator 启动后自动 dispatch 任务给其他 agents

### Claude Code 团队配置示例

如果你用 Claude Code 的 TeamCreate 功能：

```
team_name: investor-team
members:
  - name: data-fetcher
    type: general-purpose
    system_prompt: <投放 data-fetcher.md>
  - name: thesis-builder
    type: general-purpose
    system_prompt: <投放 thesis-builder.md>
  - name: red-teamer
    type: general-purpose
    system_prompt: <投放 red-teamer.md>
  - name: pm-voice
    type: general-purpose
    system_prompt: <投放 pm-voice.md>
  - name: compliance-checker
    type: general-purpose
    system_prompt: <投放 compliance-checker.md>
  - name: coordinator
    type: general-purpose
    system_prompt: 按 setup/agents/README.md 的协作流程，串联以上 5 个 agent
```

### OpenClaw 团队配置

OpenClaw 的 agent 团队定义格式略有不同，参考其官方文档把上面的角色定义转换。核心原则不变：每个 agent 一种职责，coordinator 负责串联。

### Codex 团队配置

Codex 的 multi-agent 模式可以通过子进程启动其他 agent。把每个角色保存成独立的 skill，通过协调脚本调用。

---

## 单 agent 模式（无团队）

如果你的 harness 不支持 multi-agent，或者你只想用单 agent，**仍然推荐**遵守以下纪律：

让单 agent 在每次回答投研问题时**显式经过 5 个阶段**，每个阶段输出一个 markdown section：

```markdown
## 1. Data Fetched
[实际取到的数据 + 数据源]

## 2. Thesis
[基于数据的投资命题]

## 3. Red Team
[反方观点 + 最大风险]

## 4. PM View
[决策结论 + 下一步]

## 5. Compliance
[合规检查结论]
```

这样虽然只有一个 agent，但保留了"职责分离"的输出结构，避免混淆。你可以把这个流程要求写进 workspace 的 `CLAUDE.md`。
