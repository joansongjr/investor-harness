#!/usr/bin/env bash
#
# Investor Harness · Interactive Setup Wizard
# https://github.com/joansongjr/investor-harness
#
# Usage:
#   bash setup.sh                # interactive mode
#
# What it does:
#   1. Detect OS + existing harnesses (Claude Code / Codex / OpenClaw)
#   2. Detect existing MCP configs
#   3. Install skills via symlink
#   4. Create workspace (optional)
#   5. Inject CLAUDE.md section with markers (backup original)
#   6. Verify install

set -euo pipefail

# ═══════════════════════════════════════════════════
# 常量
# ═══════════════════════════════════════════════════
HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS_VERSION="$(cat "$HARNESS_DIR/VERSION" 2>/dev/null || echo "unknown")"
TS="$(date +%Y%m%d-%H%M%S)"

# Colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
NC=$'\033[0m'

# ═══════════════════════════════════════════════════
# 状态变量（用户选择会填充这些）
# ═══════════════════════════════════════════════════
TARGET_HARNESSES=""       # "claude-code codex openclaw"
DATA_SOURCES=""           # "ifind alphapie jinmen wind websearch"
WORKSPACE_ROOT=""         # "~/investor-research"
WRITE_CLAUDE_MD="yes"     # "yes" or "no"
CLAUDE_MD_TARGET=""       # "~/.claude/CLAUDE.md"

# ═══════════════════════════════════════════════════
# 工具函数
# ═══════════════════════════════════════════════════

say() { echo "${BOLD}$*${NC}"; }
info() { echo "  ${BLUE}ℹ${NC} $*"; }
ok() { echo "  ${GREEN}✓${NC} $*"; }
warn() { echo "  ${YELLOW}⚠${NC} $*"; }
err() { echo "  ${RED}✗${NC} $*" >&2; }

hr() { echo "════════════════════════════════════════════════════════════"; }

prompt() {
  local question="$1"
  local default="${2:-}"
  local answer
  if [ -n "$default" ]; then
    read -r -p "  $question [$default]: " answer
    answer="${answer:-$default}"
  else
    read -r -p "  $question: " answer
  fi
  echo "$answer"
}

prompt_yn() {
  local question="$1"
  local default="${2:-y}"
  local hint="[y/N]"
  [ "$default" = "y" ] && hint="[Y/n]"
  local answer
  read -r -p "  $question $hint: " answer
  answer="${answer:-$default}"
  case "$answer" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

# ═══════════════════════════════════════════════════
# Banner
# ═══════════════════════════════════════════════════

show_banner() {
  echo
  hr
  echo "  ${BOLD}Investor Harness · 交互式安装向导${NC}"
  echo "  投研人的 AI 任务执行规范 · v${HARNESS_VERSION}"
  hr
  echo
  info "本向导会帮你："
  info "  1. 检测你的 AI 工具（Claude Code / Codex / OpenClaw）"
  info "  2. 配置数据源优先级"
  info "  3. 安装 17 个 sm-* skill"
  info "  4. 创建投研工作区（可选）"
  info "  5. 写入启用提示词到 ~/.claude/CLAUDE.md（自动备份）"
  info "  6. 验证安装"
  echo
  info "Harness 位置: $HARNESS_DIR"
  info "版本: $HARNESS_VERSION"
  echo
}

# ═══════════════════════════════════════════════════
# Step 1: 检测环境
# ═══════════════════════════════════════════════════

detect_environment() {
  say "▎ Step 1 · 检测环境"
  echo

  # OS
  local os
  case "$(uname -s)" in
    Darwin*) os="macOS $(sw_vers -productVersion 2>/dev/null || echo unknown)" ;;
    Linux*) os="Linux ($(uname -r))" ;;
    MINGW*|MSYS*|CYGWIN*) os="Windows ($(uname -s))" ;;
    *) os="Unknown ($(uname -s))" ;;
  esac
  ok "操作系统：$os"

  # Shell
  ok "Shell：$SHELL"

  # Bash version
  ok "Bash：${BASH_VERSION:-unknown}"

  # Git
  if command -v git >/dev/null 2>&1; then
    ok "Git：$(git --version | awk '{print $3}')"
  else
    err "Git 未安装 — 安装失败"
    exit 1
  fi

  # Harness dir
  if [ -d "$HARNESS_DIR/skills" ]; then
    ok "Harness 源文件：$HARNESS_DIR"
  else
    err "找不到 skills 目录，脚本位置不对"
    exit 1
  fi

  echo
}

# ═══════════════════════════════════════════════════
# Step 2: 选择 AI 工具
# ═══════════════════════════════════════════════════

select_harnesses() {
  say "▎ Step 2 · 选择你的 AI 工具"
  echo

  # 检测已有 harness
  local has_claude_code="no" has_codex="no" has_openclaw="no"
  local cc_mark="" cx_mark="" oc_mark=""

  [ -d "$HOME/.claude" ] && { has_claude_code="yes"; cc_mark="${GREEN}✓ 已检测到${NC}"; } || cc_mark="${YELLOW}未检测到${NC}"
  [ -d "$HOME/.codex" ] && { has_codex="yes"; cx_mark="${GREEN}✓ 已检测到${NC}"; } || cx_mark="${YELLOW}未检测到${NC}"
  [ -d "$HOME/.openclaw" ] && { has_openclaw="yes"; oc_mark="${GREEN}✓ 已检测到${NC}"; } || oc_mark="${YELLOW}未检测到${NC}"

  echo "  [1] Claude Code  ($cc_mark)"
  echo "  [2] Codex        ($cx_mark)"
  echo "  [3] OpenClaw     ($oc_mark)"
  echo "  [4] 以上全部"
  echo

  local choice
  choice=$(prompt "选择（多选用逗号隔开，如 1,2）" "1")

  TARGET_HARNESSES=""
  case "$choice" in
    *4*)
      TARGET_HARNESSES="claude-code codex openclaw"
      ;;
    *)
      [[ "$choice" == *1* ]] && TARGET_HARNESSES="$TARGET_HARNESSES claude-code"
      [[ "$choice" == *2* ]] && TARGET_HARNESSES="$TARGET_HARNESSES codex"
      [[ "$choice" == *3* ]] && TARGET_HARNESSES="$TARGET_HARNESSES openclaw"
      ;;
  esac

  if [ -z "$TARGET_HARNESSES" ]; then
    err "至少选一个"
    exit 1
  fi

  ok "选择的 harness：${TARGET_HARNESSES# }"
  echo
}

# ═══════════════════════════════════════════════════
# Step 3: 数据源配置
# ═══════════════════════════════════════════════════

detect_mcps() {
  # 检测现有 .mcp.json
  local found=""
  for mcp_path in "$HOME/.claude/mcp.json" "$HOME/.codex/mcp.json" "$HOME/.openclaw/mcp.json" "$PWD/.mcp.json"; do
    if [ -f "$mcp_path" ]; then
      found="$found $mcp_path"
    fi
  done
  echo "${found# }"
}

select_data_sources() {
  say "▎ Step 3 · 配置数据源"
  echo

  info "Investor Harness 支持 4 个付费 MCP + 免费兜底："
  info "  iFind → Alpha派 → 进门财经 → Wind → cn-web-search → WebSearch → 用户贴"
  echo

  # 检测 MCP
  local mcp_files
  mcp_files="$(detect_mcps)"

  if [ -n "$mcp_files" ]; then
    info "检测到现有 MCP 配置文件："
    for f in $mcp_files; do
      echo "    - $f"
    done
    echo
  fi

  echo "  请选择启用的数据源（多选用逗号隔开）："
  echo "  [1] iFind MCP          (同花顺投研数据，需账号)"
  echo "  [2] Alpha派 MCP         (需 API)"
  echo "  [3] 进门财经 MCP        (路演 / 专家 / 研报)"
  echo "  [4] Wind MCP           (万得资讯，企业账号)"
  echo "  [5] cn-web-search      (免费，中文搜索聚合)"
  echo "  [6] WebSearch          (harness 内置，默认可用)"
  echo "  [0] 我现在什么都没有，只用免费兜底 (= 5,6)"
  echo

  local choice
  choice=$(prompt "选择" "0")

  DATA_SOURCES=""
  if [ "$choice" = "0" ] || [ -z "$choice" ]; then
    DATA_SOURCES="cn-web-search websearch"
  else
    [[ "$choice" == *1* ]] && DATA_SOURCES="$DATA_SOURCES ifind"
    [[ "$choice" == *2* ]] && DATA_SOURCES="$DATA_SOURCES alphapie"
    [[ "$choice" == *3* ]] && DATA_SOURCES="$DATA_SOURCES jinmen"
    [[ "$choice" == *4* ]] && DATA_SOURCES="$DATA_SOURCES wind"
    [[ "$choice" == *5* ]] && DATA_SOURCES="$DATA_SOURCES cn-web-search"
    [[ "$choice" == *6* ]] && DATA_SOURCES="$DATA_SOURCES websearch"
  fi

  DATA_SOURCES="${DATA_SOURCES# }"

  # 始终包含 websearch 作为兜底
  if [[ " $DATA_SOURCES " != *" websearch "* ]]; then
    DATA_SOURCES="$DATA_SOURCES websearch"
  fi

  ok "启用的数据源：$DATA_SOURCES"

  # 对 MCP 类数据源给出配置提示
  if [[ " $DATA_SOURCES " == *" ifind "* ]]; then
    warn "iFind MCP：你需要自己在 .mcp.json 里配置 4 个 server + token"
    info "   参考：https://github.com/joansongjr/investor-harness/blob/main/docs/data-sources/ifind.md"
  fi
  if [[ " $DATA_SOURCES " == *" alphapie "* ]]; then
    warn "Alpha派 MCP：你需要自己在 .mcp.json 里配置 server + API key"
  fi
  if [[ " $DATA_SOURCES " == *" jinmen "* ]]; then
    warn "进门财经 MCP：你需要自己在 .mcp.json 里配置 server + credentials"
  fi
  if [[ " $DATA_SOURCES " == *" wind "* ]]; then
    warn "Wind MCP：需要企业账号 + 在 .mcp.json 里配置 server"
  fi

  echo
}

# ═══════════════════════════════════════════════════
# Step 4: 安装 skills
# ═══════════════════════════════════════════════════

install_skills() {
  say "▎ Step 4 · 安装 skills 到你的 AI 工具"
  echo

  for harness in $TARGET_HARNESSES; do
    local target_dir
    case "$harness" in
      claude-code) target_dir="$HOME/.claude/skills" ;;
      codex)       target_dir="$HOME/.codex/skills" ;;
      openclaw)    target_dir="$HOME/.openclaw/skills" ;;
      *) continue ;;
    esac

    mkdir -p "$target_dir"
    local link="$target_dir/investor-harness"

    if [ -L "$link" ]; then
      local current
      current="$(readlink "$link")"
      if [ "$current" = "$HARNESS_DIR" ]; then
        ok "$harness: 已链接 → $HARNESS_DIR"
        continue
      else
        warn "$harness: 存在旧链接 → $current"
        if prompt_yn "覆盖？" "y"; then
          rm -f "$link"
          ln -s "$HARNESS_DIR" "$link"
          ok "$harness: 已更新链接"
        fi
      fi
    elif [ -e "$link" ]; then
      warn "$harness: $link 存在但不是软链接"
      if prompt_yn "备份并覆盖？" "y"; then
        mv "$link" "${link}.backup-${TS}"
        ln -s "$HARNESS_DIR" "$link"
        ok "$harness: 已备份并创建新链接"
      fi
    else
      ln -s "$HARNESS_DIR" "$link"
      ok "$harness: 链接已创建 → $HARNESS_DIR"
    fi
  done

  echo
}

# ═══════════════════════════════════════════════════
# Step 5: 创建工作区
# ═══════════════════════════════════════════════════

create_workspace() {
  say "▎ Step 5 · 创建投研工作区"
  echo

  if ! prompt_yn "创建一个分析师工作区？（包含 coverage.md / decision-log.md 等模板）" "y"; then
    info "跳过工作区创建"
    WORKSPACE_ROOT=""
    echo
    return
  fi

  local default_ws="$HOME/investor-research"
  WORKSPACE_ROOT=$(prompt "工作区路径" "$default_ws")

  # 展开 ~
  WORKSPACE_ROOT="${WORKSPACE_ROOT/#\~/$HOME}"

  if [ -d "$WORKSPACE_ROOT" ] && [ -f "$WORKSPACE_ROOT/CLAUDE.md" ]; then
    warn "$WORKSPACE_ROOT 已存在且包含 CLAUDE.md"
    if ! prompt_yn "强制覆盖？（原文件会被备份）" "n"; then
      info "跳过工作区创建"
      return
    fi
    bash "$HARNESS_DIR/setup/bootstrap.sh" "$WORKSPACE_ROOT" --force
  else
    bash "$HARNESS_DIR/setup/bootstrap.sh" "$WORKSPACE_ROOT"
  fi

  ok "工作区创建完成：$WORKSPACE_ROOT"
  echo
}

# ═══════════════════════════════════════════════════
# Step 6: 注入 CLAUDE.md 启用提示词
# ═══════════════════════════════════════════════════

build_data_sources_chain() {
  # 根据用户选择的数据源生成优先级链文本
  local chain=""
  chain="${chain}**A 股 / 公募 (CN-A / CN-FUND)**:\n"
  local idx=1
  [[ " $DATA_SOURCES " == *" ifind "* ]] && { chain="${chain}  $idx. iFind MCP (get_stock_summary / get_stock_financials / search_stocks 等)\n"; idx=$((idx+1)); }
  [[ " $DATA_SOURCES " == *" alphapie "* ]] && { chain="${chain}  $idx. Alpha派 MCP (补充 / 互验)\n"; idx=$((idx+1)); }
  [[ " $DATA_SOURCES " == *" wind "* ]] && { chain="${chain}  $idx. Wind MCP (高质量财务数据)\n"; idx=$((idx+1)); }
  [[ " $DATA_SOURCES " == *" jinmen "* ]] && { chain="${chain}  $idx. 进门财经 MCP (路演 / 专家 / 研报)\n"; idx=$((idx+1)); }
  [[ " $DATA_SOURCES " == *" cn-web-search "* ]] && { chain="${chain}  $idx. cn-web-search skill\n"; idx=$((idx+1)); }
  [[ " $DATA_SOURCES " == *" websearch "* ]] && { chain="${chain}  $idx. WebSearch（兜底）\n"; idx=$((idx+1)); }
  chain="${chain}  $idx. 用户手动贴材料\n"

  chain="${chain}\n**港股 / 美股 / 跨市场**:\n"
  idx=1
  [[ " $DATA_SOURCES " == *" wind "* ]] && { chain="${chain}  $idx. Wind MCP (全球覆盖)\n"; idx=$((idx+1)); }
  [[ " $DATA_SOURCES " == *" websearch "* ]] && { chain="${chain}  $idx. WebSearch (SEC EDGAR / HKEX)\n"; idx=$((idx+1)); }
  chain="${chain}  $idx. 用户手动贴材料\n"

  printf "%b" "$chain"
}

render_claude_md_section() {
  local date_str ws_root coverage_root harness_path data_sources_str chain
  date_str="$(date +%Y-%m-%d)"
  ws_root="${WORKSPACE_ROOT:-~/investor-research}"
  coverage_root="${ws_root}/coverage"
  harness_path="$HARNESS_DIR"
  data_sources_str="$(echo "$DATA_SOURCES" | tr ' ' ',')"
  chain="$(build_data_sources_chain)"

  cat <<EOF
<!-- INVESTOR_HARNESS:BEGIN v${HARNESS_VERSION} -->
<!-- DO NOT EDIT MANUALLY — managed by investor-harness setup.sh / update.sh -->

# Investor Harness · 投研工作纪律（自动注入，勿改）

**version**: v${HARNESS_VERSION}
**last_updated**: ${date_str}
**harness_path**: ${harness_path}
**workspace_root**: ${ws_root}
**data_sources**: ${data_sources_str}

## 启动协议（每次新会话第一件事）

1. 读 \`${harness_path}/core/_boot.md\`（~1.2k tokens）
2. 检查当前目录的 \`.task-pulse\` 文件
3. 如有 in_progress 任务 → 主动告知用户："你有 N 个进行中任务，要继续哪一个？"
4. **不要默认从头开始，先问**

## 自动路由规则

我做投研任务时（股票、基金、行业、公司、财报、宏观、投资决策），你必须按 Investor Harness 纪律工作。**这是硬约束，不是建议**。

| 我说 | 你做 |
|---|---|
| "看一下 X" / "X 怎么样" | 走 \`sm-autopilot\` 自动路由 |
| "深度看 X" / "起 coverage" | 走 \`sm-company-deepdive\` |
| "X 财报前瞻" | 走 \`sm-earnings-preview\` |
| "反过来想 X" / "X 空头逻辑" | 走 \`sm-red-team\` |
| "X 预期差" | 走 \`sm-consensus-watch\` |
| "整理今天的 X" / "晨会" | 走 \`sm-briefing\` |
| "给 PM 一页纸" | 走 \`sm-pm-brief\` |
| "X 行业框架" | 走 \`sm-industry-map\` |
| "怎么问 X 管理层" | 走 \`sm-roadshow-questions\` |
| "看 X 的 K 线" / "复盘 X" | 走 \`sm-tape-review\` |
| "刷新覆盖池" | 走 \`sm-batch-refresh\` |
| "扫事件" | 走 \`sm-catalyst-sweep\` |

## Skill 调用的强制流程

**开始前 Preamble 6 步**（读 \`${harness_path}/core/preamble.md\`）：
0. 检查 .task-pulse 续跑
1. 识别市场
2. 检查历史输出
3. 检查 active-tasks
4. **必须**输出 \`[Preflight]\` 取数计划
5. 实际取数

**输出时**：按 skill 结构；每条事实带 F1/F2/M1/C1/H1 证据等级；风险必须可观测可触发。

**结束后 Postamble 8 步**（读 \`${harness_path}/core/postamble.md\`）：
0. 每完成一段写 .checkpoint
1. 证据等级自检
2. "仍需补的资料"段非空
3. 合规声明
4. 归档到 \`${coverage_root}/{ticker}/{skill}/YYYY-MM-DD-{skill}.md\`
5. 更新 .task-pulse + active-tasks.md
6. 验收清单
7. **Dual Output** — 对话贴完整输出 + 同时写文件；末尾追加 📁 已归档提示 + 关键统计

⛔ **不要只回摘要**——云端用户打不开本地文件。

## 数据源优先级（本机配置）

${chain}

## 17 个 skill

sm-master · sm-autopilot · sm-thesis · sm-industry-map · sm-company-deepdive · sm-earnings-preview · sm-model-check · sm-consensus-watch · sm-catalyst-monitor · sm-roadshow-questions · sm-red-team · sm-pm-brief · sm-briefing · sm-tape-review · sm-batch-refresh · sm-batch-earnings · sm-catalyst-sweep

## 硬约束

❌ 不编造数字 · 不混淆事实与猜测 · 不写套话风险 · 不给目标价评级 · 不承诺收益 · 不只回摘要 · 不跳过 Preflight · 不忘记"仍需补的资料"段

## Context Overflow

剩余 > 30k 正常；< 30k 提醒；< 10k 强制写 checkpoint 后停止

## 默认行为

- 模糊请求（"看看 X"）→ sm-autopilot
- 不主动追问；信息不足时列"不知道什么"而不是猜

<!-- INVESTOR_HARNESS:END -->
EOF
}

inject_claude_md() {
  say "▎ Step 6 · 写入启用提示词到 CLAUDE.md"
  echo

  info "启用提示词是让 LLM 自动按 Investor Harness 规则工作的关键一步。"
  info "（如果不做这一步，LLM 看到'看一下 LITE'还会给你百度百科段落）"
  echo

  # 目标文件
  local default_target="$HOME/.claude/CLAUDE.md"
  CLAUDE_MD_TARGET=$(prompt "写入到哪个 CLAUDE.md？" "$default_target")
  CLAUDE_MD_TARGET="${CLAUDE_MD_TARGET/#\~/$HOME}"

  # 确保父目录存在
  mkdir -p "$(dirname "$CLAUDE_MD_TARGET")"

  local new_section
  new_section="$(render_claude_md_section)"

  if [ -f "$CLAUDE_MD_TARGET" ]; then
    # 备份
    local backup="${CLAUDE_MD_TARGET}.backup-${TS}"
    cp "$CLAUDE_MD_TARGET" "$backup"
    ok "备份原文件到 $backup"

    # 检查是否已有 marker
    if grep -q "<!-- INVESTOR_HARNESS:BEGIN" "$CLAUDE_MD_TARGET"; then
      # 已有 marker，替换中间内容
      info "检测到已有 Investor Harness 段（marker），替换内容..."
      local tmp="${CLAUDE_MD_TARGET}.tmp.${TS}"
      awk -v new_content="$new_section" '
        /<!-- INVESTOR_HARNESS:BEGIN/ { in_block=1; print new_content; next }
        /<!-- INVESTOR_HARNESS:END -->/ { in_block=0; next }
        !in_block { print }
      ' "$CLAUDE_MD_TARGET" > "$tmp"
      mv "$tmp" "$CLAUDE_MD_TARGET"
      ok "已更新 marker 之间的内容"
    else
      # 没有 marker，追加到末尾
      info "未检测到 marker，追加到文件末尾..."
      echo "" >> "$CLAUDE_MD_TARGET"
      echo "$new_section" >> "$CLAUDE_MD_TARGET"
      ok "已追加"
    fi
  else
    # 新文件
    echo "$new_section" > "$CLAUDE_MD_TARGET"
    ok "已创建 $CLAUDE_MD_TARGET"
  fi

  echo
}

# ═══════════════════════════════════════════════════
# Step 7: 验证
# ═══════════════════════════════════════════════════

verify_install() {
  say "▎ Step 7 · 验证安装"
  echo

  local errors=0

  # 1. Skills 链接
  for harness in $TARGET_HARNESSES; do
    local target
    case "$harness" in
      claude-code) target="$HOME/.claude/skills/investor-harness" ;;
      codex)       target="$HOME/.codex/skills/investor-harness" ;;
      openclaw)    target="$HOME/.openclaw/skills/investor-harness" ;;
    esac
    if [ -L "$target" ] && [ -d "$target" ]; then
      ok "$harness skills 链接正常"
    else
      err "$harness skills 链接缺失"
      errors=$((errors+1))
    fi
  done

  # 2. CLAUDE.md 注入
  if [ -f "$CLAUDE_MD_TARGET" ] && grep -q "INVESTOR_HARNESS:BEGIN" "$CLAUDE_MD_TARGET"; then
    ok "CLAUDE.md 启用提示词已写入"
  else
    warn "CLAUDE.md 启用提示词未检测到（可能你选择了跳过）"
  fi

  # 3. Workspace
  if [ -n "$WORKSPACE_ROOT" ] && [ -d "$WORKSPACE_ROOT" ]; then
    ok "工作区：$WORKSPACE_ROOT"
    [ -f "$WORKSPACE_ROOT/.task-pulse" ] && ok "  .task-pulse 存在" || warn "  .task-pulse 缺失"
    [ -d "$WORKSPACE_ROOT/.checkpoint" ] && ok "  .checkpoint/ 存在" || warn "  .checkpoint/ 缺失"
  fi

  echo
  return $errors
}

# ═══════════════════════════════════════════════════
# 完成
# ═══════════════════════════════════════════════════

show_completion() {
  echo
  hr
  say "  ✅ 安装完成"
  hr
  echo
  info "资源位置："
  info "  Harness 源:     $HARNESS_DIR"
  [ -n "$WORKSPACE_ROOT" ] && info "  工作区:         $WORKSPACE_ROOT"
  info "  启用提示词:     $CLAUDE_MD_TARGET"
  echo
  info "下一步："
  info "  1. ${BOLD}重启你的 AI 工具${NC}（Claude Code / Codex / OpenClaw）"
  [ -n "$WORKSPACE_ROOT" ] && info "  2. cd ${WORKSPACE_ROOT}"
  info "  3. 随便问一家公司，比如：'看一下 LITE'"
  info "  4. 验证：LLM 应该先输出 [Preflight] 取数计划，而不是直接给百度百科段落"
  echo
  info "有问题？"
  info "  Issues:    https://github.com/joansongjr/investor-harness/issues"
  info "  文档:      https://github.com/joansongjr/investor-harness"
  info "  更新:      cd $HARNESS_DIR && bash update.sh"
  echo
}

# ═══════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════

main() {
  show_banner
  detect_environment
  select_harnesses
  select_data_sources
  install_skills
  create_workspace
  inject_claude_md
  verify_install
  show_completion
}

main "$@"
