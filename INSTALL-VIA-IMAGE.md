# Investor Harness · 图片驱动安装指南

> **给 AI agent 看的执行文档**——当你（agent）从用户那里收到下面这两张图片时，按本文档执行。
>
> 这是**零门槛安装**：用户无需懂技术，只需发图，你自主完成全部安装与配置。

---

## 📷 图片 1 · 安装触发指令

**用户发给 agent 的图 1 通常是这样的内容**：

> 之前没下载过想体验一下的老师可以把这张图发给自己的 workbuddy/codex/claudecode/opencode/cursor/deepseek/kimi code 等使用~
>
> 【请帮我从 https://github.com/joansongjr/investor-harness 上安装整个 investor-harness，并执行 onboarding，安装后请向我介绍它的主要功能】

**触发关键词识别**：
- `从 https://github.com/joansongjr/investor-harness 上安装`
- `执行 onboarding`
- `向我介绍它的主要功能`

收到图 1 → **走下方"图 1 执行流程"**

## 📷 图片 2 · 知识库锚点指令

**用户发给 agent 的图 2 通常是这样的内容**：

> 【我的知识库在 xx 文件夹存着，按照 harness 的规范，每次都调用里面的内容，并且把生成的结果存在这个文件夹里对应的位置，把这个位置和这段要求放在 agent.md 文件最顶层】

**触发关键词识别**：
- `我的知识库在` 或 `知识库在`
- `按照 harness 的规范` 或 `按 harness 规范`
- `放在 .* 文件最顶层` 或 `放在 .* 最顶层`

三个关键词同时命中 → **走下方"图 2 执行流程"**

---

## 图 1 执行流程（收到图 1 时）

### Step 1 · 检测你自己是什么 agent

按以下顺序探测（**用 `ls -d` 或 `test -d`**，不要靠猜）：

| 检测命令 | 命中 → 你是 |
|---|---|
| `test -d ~/.workbuddy` | **WorkBuddy** |
| `test -d ~/.claude` | Claude Code |
| `test -d ~/.codex` | Codex |
| `test -d ~/.opencode` 或 `test -d ~/.config/opencode` | OpenCode |
| `test -d ~/.openclaw` | OpenClaw |
| `command -v cursor` | Cursor |
| `command -v deepseek` | DeepSeek |
| `command -v kimi` 或 `test -d ~/.kimi` | Kimi Code |
| 都没命中 | **通用 fallback**（用 generic.sh 写到自定义目录） |

如果命中多个，按表格顺序选第一个（**WorkBuddy 优先**）。

### Step 2 · 选择 install 脚本并安装

```bash
# 先克隆
git clone https://github.com/joansongjr/investor-harness.git ~/investor-harness
cd ~/investor-harness

# 然后根据你的类型选脚本
case "你的类型" in
  workbuddy)    bash install/workbuddy.sh ;;
  claude-code)  bash install/claude-code.sh ;;
  codex)        bash install/codex.sh ;;
  opencode)     bash install/opencode.sh ;;
  cursor|deepseek|kimi|*)
               bash install/generic.sh ~/.{your-harness}/skills ;;
esac
```

> 💡 **懒人方案**：如果你不想判断类型，直接 `bash setup.sh --auto`，它会帮你自动检测并安装（无需交互）。

### Step 3 · 跑 onboarding

onboarding 流程在 `ONBOARDING.md`。**严格按 9 步执行**：

1. 第 0 步：检测是否已 onboard（grep `investor-harness:keyword-routes`）
2. 第 0.5 步：工作区骨架审计
3. 第 1 步：展示 32 个 skill 清单 + 关键词路由表（从 `setup/keyword-routes.md` 拉，**不省略任何一行**）
4. 第 2 步：解释三种激活方式
5. 第 3 步：请求明确"同意"（**⛔ 硬约束：未明确同意不写文件**）
6. 第 4 步：检测 harness + 入口 MD 路径
7. **第 4.5 步：知识库锚点**（如果用户消息包含图 2 关键词，必须处理）
8. 第 5 步：写入路由块
9. 第 6 步：验证
10. 第 7 步：工作区补建
11. 第 8 步：归档硬约束
12. 第 9 步：判断 onboarding 完成

### Step 4 · 介绍主要功能

按 `setup/keyword-routes.md` 的分类展示 32 个 skill（**默认路由 26 个 + Librarian opt-in 6 个**），包含触发关键词。然后展示 `README.md` 里的"核心能力"对比（裸 LLM vs Investor Harness）。

---

## 图 2 执行流程（收到图 2 时）

**严格按照 `ONBOARDING.md` 第 4.5 步执行**：

### Step 1 · 检测图 2 关键词
三个关键词同时命中才走本流程：
- `我的知识库在` / `知识库在`
- `按 harness 规范` / `按照 harness 的规范`
- `放在 .* 文件最顶层`

### Step 2 · 解析知识库路径
从用户消息里提取 `xx 文件夹`的路径，展开 `~`。

### Step 3 · dry-run 展示
读取 `setup/knowledge-base-anchor.template.md`，替换占位符：
- `{{KB_PATH}}` → 用户知识库路径
- `{{HARNESS_PATH}}` → `~/investor-harness`

完整展示给用户，**明确告知会插入到入口文件最顶层**（不是追加）。

### Step 4 · 等待用户明确同意
⛔ "先看看 / 再想想 / 我自己来" → 绝对不写

### Step 5 · 写入（关键：插入最顶层，不是追加）

**Claude Code / Codex / OpenCode / OpenClaw**：
```bash
# 1. 读入口 MD
TARGET=~/.claude/CLAUDE.md   # 或对应 harness 的入口

# 2. 拼接：锚点 + 空行 + 原内容
ANCHOR="$(cat ~/investor-harness/setup/knowledge-base-anchor.template.md)"
ANCHOR_RENDERED="$(echo "$ANCHOR" | sed "s|{{KB_PATH}}|$KB_PATH|g; s|{{HARNESS_PATH}}|~/investor-harness|g")"
echo "$ANCHOR_RENDERED" > /tmp/new_entry.md
echo "" >> /tmp/new_entry.md
cat "$TARGET" >> /tmp/new_entry.md
mv /tmp/new_entry.md "$TARGET"

# 3. 验证（head -20 应能看到"# 📚 知识库锚点"）
head -20 "$TARGET"
```

**WorkBuddy**（特殊处理：写到 MEMORY.md 顶层，不动 SKILL.md）：
```bash
# 写到 ~/.workbuddy/MEMORY.md 或 ${PWD}/.workbuddy/memory/MEMORY.md 的最顶层
# 同样用"锚点 + 空行 + 原内容"模式
```

### Step 6 · 告知用户
> ✅ 知识库锚点已写入 `<target>` 最顶层
> 📁 知识库路径：`<KB_PATH>`
> 🔄 重启会话即生效（agent 第一件事读到知识库路径）

---

## 两图联用的顺序

如果用户**先发图 1，再发图 2**（推荐顺序）：

1. 图 1 → 装 harness + 跑 onboarding
2. 图 2 → 在 onboarding 第 4.5 步处理（写入知识库锚点）
3. 完成

如果用户**先发图 2，再发图 1**：

1. 图 2 → 此时 harness 还没装，"入口文件"还不存在
   - **处理**：先按图 1 流程装好 harness，再应用图 2 锚点（onboarding 第 4.5 步处理）
2. 图 1 → 装 + onboarding（含第 4.5 步处理图 2）
3. 完成

如果用户**只发图 1**，没发图 2：
- 跳过第 4.5 步，正常完成 onboarding

如果用户**只发图 2**，没发图 1：
- 需要先引导用户发图 1 装 harness，再处理图 2 锚点

---

## 关键硬约束（不可绕过）

⛔ **未读到用户明确"同意" / "agree" / "yes, write it"** → agent **绝对不**写任何文件

⛔ **未识别出自己是什么 agent 类型** → 先检测，再选 install 脚本；不要猜

⛔ **知识库锚点必须插入最顶层，不是追加到末尾**——这是图 2 用户的核心要求

⛔ **不可绕过 preamble/postamble**——任何投研任务都按 harness 6 步开头 + 8 步结尾

⛔ **结果必须同时贴对话 + 归档到知识库对应位置**（Dual Output Discipline）

---

## 常见错误

### ❌ 错误 1：把知识库锚点追加到入口文件末尾
图 2 用户明确要求"**放在 agent.md 文件最顶层**"。必须插入顶层，不能追加。

### ❌ 错误 2：猜测 agent 类型
不检测直接跑 install/claude-code.sh 是错的。用 `test -d` 检测。

### ❌ 错误 3：跳过 onboarding
图 1 明确要求"执行 onboarding"。装完不等于激活，必须跑 onboarding 9 步流程。

### ❌ 错误 4：忽略图 2 的"按 harness 规范"
图 2 不只是写路径，**还要求按 harness 规范调用本地资料 + 结果回写**。写入锚点时这两条硬约束必须包含。

---

## 升级 / 重新触发

- 用户说"重新跑 onboarding" → 走 `ONBOARDING.md` 全流程
- 用户说"升级 harness" → 读 `UPGRADE-PROMPT.md`
- 用户说"移除知识库锚点" → 找 `<!-- investor-harness:knowledge-base-anchor:start -->...:end -->` 整块删除
- 用户说"更新路由表" → 走 `ONBOARDING.md` 第 5 步（marker 替换）

---

**License**: MIT © 2026 Joan Song