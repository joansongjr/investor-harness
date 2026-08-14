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
#   5. Inject entrypoint MD section with markers (backup original)
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
ENTRY_MD_TARGET=""        # "~/.claude/CLAUDE.md" / "~/.codex/AGENTS.md"

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

entry_md_target_for_harness() {
  case "$1" in
    claude-code) printf '%s\n' "$HOME/.claude/CLAUDE.md" ;;
    codex)       printf '%s\n' "$HOME/.codex/AGENTS.md" ;;
    openclaw)    printf '%s\n' "$HOME/.openclaw/CLAUDE.md" ;;
    opencode)    printf '%s\n' "$HOME/.config/opencode/AGENTS.md" ;;
    # WorkBuddy 不写入口 MD——靠 ~/.workbuddy/skills/investor-harness/SKILL.md 自动激活
    workbuddy)   printf '%s\n' "none" ;;
    *)           return 1 ;;
  esac
}

default_entry_md_target() {
  local harness
  # 跳过 workbuddy（它不写入口 MD），取第一个需要写入口 MD 的 harness
  for harness in $TARGET_HARNESSES; do
    [ "$harness" = "workbuddy" ] && continue
    entry_md_target_for_harness "$harness"
    return 0
  done
  # 全是 workbuddy → 不需要入口 MD
  printf '%s\n' "none"
}

# 判断是否选择了至少一个非 workbuddy harness（需要写入口 MD的）
has_entry_md_harness() {
  local harness
  for harness in $TARGET_HARNESSES; do
    [ "$harness" != "workbuddy" ] && return 0
  done
  return 1
}

# 自动检测 harness 类型（图片驱动安装 / NO_PROMPT 模式用）
# 按优先级：WorkBuddy > Claude Code > Codex > OpenCode > OpenClaw
auto_detect_harness() {
  [ -d "$HOME/.workbuddy" ] && { echo "workbuddy"; return; }
  [ -d "$HOME/.claude" ] && { echo "claude-code"; return; }
  [ -d "$HOME/.codex" ] && { echo "codex"; return; }
  [ -d "$HOME/.config/opencode" ] && { echo "opencode"; return; }
  [ -d "$HOME/.opencode" ] && { echo "opencode"; return; }
  [ -d "$HOME/.openclaw" ] && { echo "openclaw"; return; }
  echo ""
}

replace_managed_block() {
  local target="$1"
  local start_regex="$2"
  local end_regex="$3"
  local replacement_file="$4"
  local tmp="${target}.tmp.${TS}"

  awk -v start_regex="$start_regex" -v end_regex="$end_regex" -v replacement_file="$replacement_file" '
    $0 ~ start_regex {
      in_block=1
      while ((getline line < replacement_file) > 0) print line
      close(replacement_file)
      next
    }
    in_block && $0 ~ end_regex { in_block=0; next }
    !in_block { print }
  ' "$target" > "$tmp"

  mv "$tmp" "$target"
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
  info "  1. 检测你的 AI 工具（Claude Code / Codex / OpenClaw / WorkBuddy）"
  info "  2. 配置数据源优先级"
  info "  3. 安装 32 个 sm-* skill"
  info "  4. 创建投研工作区（可选）"
  info "  5. 写入启用提示词到入口 MD（WorkBuddy 靠 SKILL.md 自动激活，无需此步）"
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
  # --auto / NO_PROMPT 模式：自动检测 harness，不询问
  if [[ "${AUTO_MODE:-0}" == "1" ]] || [[ "${NO_PROMPT:-0}" == "1" ]]; then
    local auto_harness
    auto_harness="$(auto_detect_harness)"
    if [[ -n "$auto_harness" ]]; then
      TARGET_HARNESSES="$auto_harness"
      ok "[auto 模式] 检测到 $auto_harness，自动选择（跳过询问）"
      echo
      return
    else
      err "[auto 模式] 未检测到任何 harness（~/.claude / ~/.codex / ~/.workbuddy / ~/.opencode / ~/.openclaw 都不存在）"
      err "请先安装 Claude Code / Codex / OpenCode / WorkBuddy / OpenClaw，或手动跑 setup.sh（不带 --auto）"
      exit 1
    fi
  fi

  say "▎ Step 2 · 选择你的 AI 工具"
  echo

  # 检测已有 harness
  local has_claude_code="no" has_codex="no" has_openclaw="no" has_workbuddy="no"
  local cc_mark="" cx_mark="" oc_mark="" wb_mark=""

  [ -d "$HOME/.claude" ] && { has_claude_code="yes"; cc_mark="${GREEN}✓ 已检测到${NC}"; } || cc_mark="${YELLOW}未检测到${NC}"
  [ -d "$HOME/.codex" ] && { has_codex="yes"; cx_mark="${GREEN}✓ 已检测到${NC}"; } || cx_mark="${YELLOW}未检测到${NC}"
  [ -d "$HOME/.openclaw" ] && { has_openclaw="yes"; oc_mark="${GREEN}✓ 已检测到${NC}"; } || oc_mark="${YELLOW}未检测到${NC}"
  [ -d "$HOME/.workbuddy" ] && { has_workbuddy="yes"; wb_mark="${GREEN}✓ 已检测到${NC}"; } || wb_mark="${YELLOW}未检测到${NC}"

  echo "  [1] Claude Code  ($cc_mark)"
  echo "  [2] Codex        ($cx_mark)"
  echo "  [3] OpenClaw     ($oc_mark)"
  echo "  [4] WorkBuddy     ($wb_mark)"
  echo "  [5] 以上全部"
  echo
  echo "  注：WorkBuddy 不写入口 MD，靠 ~/.workbuddy/skills/investor-harness/SKILL.md 自动激活"
  echo

  local choice
  choice=$(prompt "选择（多选用逗号隔开，如 1,2）" "1")

  TARGET_HARNESSES=""
  case "$choice" in
    *5*)
      TARGET_HARNESSES="claude-code codex openclaw workbuddy"
      ;;
    *)
      [[ "$choice" == *1* ]] && TARGET_HARNESSES="$TARGET_HARNESSES claude-code"
      [[ "$choice" == *2* ]] && TARGET_HARNESSES="$TARGET_HARNESSES codex"
      [[ "$choice" == *3* ]] && TARGET_HARNESSES="$TARGET_HARNESSES openclaw"
      [[ "$choice" == *4* ]] && TARGET_HARNESSES="$TARGET_HARNESSES workbuddy"
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
  for mcp_path in "$HOME/.claude/mcp.json" "$HOME/.codex/mcp.json" "$HOME/.openclaw/mcp.json" "$HOME/.workbuddy/.mcp.json" "$PWD/.mcp.json"; do
    if [ -f "$mcp_path" ]; then
      printf '%s\n' "$mcp_path"
    fi
  done
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
    while IFS= read -r f; do
      [ -n "$f" ] && echo "    - $f"
    done <<< "$mcp_files"
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
      workbuddy)   target_dir="$HOME/.workbuddy/skills" ;;
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

  if [ -d "$WORKSPACE_ROOT" ] && { [ -f "$WORKSPACE_ROOT/CLAUDE.md" ] || [ -f "$WORKSPACE_ROOT/AGENTS.md" ]; }; then
    warn "$WORKSPACE_ROOT 已存在且包含入口 MD（CLAUDE.md 或 AGENTS.md）"
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
# Step 6: 注入入口 MD 启用提示词
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

render_entry_md_section() {
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
| "看看 X" / "X 怎么样" / "帮我看下 X" | 走 \`sm-autopilot\` 自动路由 |
| "master 模式" / "总控" / "全套跑一遍 X" | 走 \`sm-master\` |
| "X 投资命题" / "做 X 的 thesis" / "X 投资逻辑" | 走 \`sm-thesis\` |
| "X 行业框架" / "X 产业链地图" / "X 行业全景" | 走 \`sm-industry-map\` |
| "X 深度报告" / "深度看 X" / "起 X 的 coverage" | 走 \`sm-company-deepdive\` |
| "X 财报前瞻" / "X earnings preview" / "X 业绩前瞻" | 走 \`sm-earnings-preview\` |
| "审 X 的模型" / "X 模型 sanity check" / "X 模型审阅" | 走 \`sm-model-check\` |
| "X 预期差" / "X consensus" / "X 一致预期" | 走 \`sm-consensus-watch\` |
| "X 催化剂" / "X catalyst" / "X 事件跟踪" | 走 \`sm-catalyst-monitor\` |
| "怎么问 X 管理层" / "X 调研提纲" / "X 路演问题" | 走 \`sm-roadshow-questions\` |
| "反过来想 X" / "X 空头逻辑" / "X red team" / "X 反方" | 走 \`sm-red-team\` |
| "给 PM 一页纸" / "X 的 PM brief" / "IC 一页纸" | 走 \`sm-pm-brief\` |
| "整理今天的 X" / "晨会" | 走 \`sm-briefing\` |
| "看 X 的 K 线" / "复盘 X" / "X 盘面" / "X 技术面" | 走 \`sm-tape-review\` |
| "做 X 的 deck" / "X 的 IC pitch PPT" / "X 路演 PPT" / "X 客户 pitch" | 走 \`sm-deck-builder\` |
| "刷新覆盖池" / "批量过 X 列表" / "coverage refresh" | 走 \`sm-batch-refresh\` |
| "财报季批量" / "批量前瞻" / "batch earnings" | 走 \`sm-batch-earnings\` |
| "扫事件" / "今天有什么催化" / "catalyst sweep" | 走 \`sm-catalyst-sweep\` |
| "起 X 的 wiki page" / "建 X 的 coverage" / "onboard X" | 走 \`sm-wiki-build\`（仅用户明示时） |
| "刷 daily feed" / "跑每日扫描" / "今天看一下覆盖池" | 走 \`sm-daily-feed\`（仅用户明示时） |
| "见 X 前过一遍 question list" / "准备 X 调研提纲" / "会前 briefing" | 走 \`sm-question-list\`（仅用户明示时） |
| "跑健康检查" / "扫跨源矛盾" / "wiki 自检" | 走 \`sm-health-check\`（仅用户明示时） |
| "会后归档" / "整理 X 的 Q&A" / "见完 X 后整理" | 走 \`sm-qa-archive\`（仅用户明示时） |

## Skill 调用的强制流程

**开始前 Preamble 6 步**（读 \`${harness_path}/core/preamble.md\`）：
0. 检查 .task-pulse 续跑
1. 识别市场
2. 检查历史输出
3. 检查 active-tasks
4. **必须**输出 \`[Preflight]\` 取数计划
5. 实际取数

**输出时**：按 skill 结构；每条事实带完整中文证据等级；风险必须可观测可触发。

**结束后 Postamble 8 步**（读 \`${harness_path}/core/postamble.md\`）：
0. 每完成一段写 .checkpoint
1. 证据等级自检
2. "仍需补的资料"段非空
3. 合规声明
4. 归档到 \`${coverage_root}/{ticker}_{name}/{skill}/YYYY-MM-DD-{skill}.md\`
5. 更新 .task-pulse + active-tasks.md
6. 验收清单
7. **Dual Output** — 对话贴完整输出 + 同时写文件；末尾追加 📁 已归档提示 + 关键统计

⛔ **不要只回摘要**——云端用户打不开本地文件。

## 数据源优先级（本机配置）

${chain}

## 32 个 skill

sm-master · sm-autopilot · sm-thesis · sm-industry-map · sm-company-deepdive · sm-valuation · sm-earnings-preview · sm-model-check · sm-consensus-watch · sm-industry-database · sm-catalyst-monitor · sm-roadshow-questions · sm-red-team · sm-pm-brief · sm-briefing · sm-tape-review · sm-quant-tape · sm-deck-builder · sm-batch-refresh · sm-batch-earnings · sm-catalyst-sweep · sm-stock-screen · sm-hourly-watch · sm-close-recap · sm-supervisor · sm-learn · sm-wiki-build · sm-daily-feed · sm-question-list · sm-health-check · sm-qa-archive · sm-people-watch

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

inject_entry_md() {
  # WorkBuddy-only：不需要写入口 MD，靠 ~/.workbuddy/skills/investor-harness/SKILL.md 自动激活
  if ! has_entry_md_harness; then
    say "▎ Step 6 · WorkBuddy 激活（无需入口 MD）"
    echo
    info "WorkBuddy 不读 CLAUDE.md / AGENTS.md——靠根目录 SKILL.md 自动激活。"
    info "已安装到：$HOME/.workbuddy/skills/investor-harness/SKILL.md"
    echo
    ok "WorkBuddy skill 已就绪，重启会话即按 description 自动触发"
    echo
    info "可选增强：在 WorkBuddy 里说'跑一下 investor-harness onboarding'"
    info "       会引导你把路由表写入 ~/.workbuddy/MEMORY.md 做持久底座"
    echo
    ENTRY_MD_TARGET="none"
    return 0
  fi

  say "▎ Step 6 · 写入启用提示词到入口 MD"
  echo

  info "启用提示词是让 LLM 自动按 Investor Harness 规则工作的关键一步。"
  info "（如果不做这一步，LLM 看到'看一下 LITE'还会给你百度百科段落）"
  echo

  # 目标文件
  local default_target
  default_target="$(default_entry_md_target)"
  ENTRY_MD_TARGET=$(prompt "写入到哪个入口 MD？" "$default_target")
  ENTRY_MD_TARGET="${ENTRY_MD_TARGET/#\~/$HOME}"

  # 确保父目录存在
  mkdir -p "$(dirname "$ENTRY_MD_TARGET")"

  local new_section
  new_section="$(render_entry_md_section)"
  local section_file
  section_file="$(mktemp "${TMPDIR:-/tmp}/investor-harness-section.XXXXXX")"
  printf '%s\n' "$new_section" > "$section_file"

  if [ -f "$ENTRY_MD_TARGET" ]; then
    # 备份
    local backup="${ENTRY_MD_TARGET}.backup-${TS}"
    cp "$ENTRY_MD_TARGET" "$backup"
    ok "备份原文件到 $backup"

    # 检查是否已有 marker
    if grep -q "<!-- INVESTOR_HARNESS:BEGIN" "$ENTRY_MD_TARGET"; then
      # 已有 marker，替换中间内容
      info "检测到已有 Investor Harness 段（marker），替换内容..."
      replace_managed_block "$ENTRY_MD_TARGET" "^<!-- INVESTOR_HARNESS:BEGIN" "^<!-- INVESTOR_HARNESS:END -->$" "$section_file"
      ok "已更新 marker 之间的内容"
    else
      # 没有 marker，追加到末尾
      info "未检测到 marker，追加到文件末尾..."
      echo "" >> "$ENTRY_MD_TARGET"
      cat "$section_file" >> "$ENTRY_MD_TARGET"
      ok "已追加"
    fi
  else
    # 新文件
    cat "$section_file" > "$ENTRY_MD_TARGET"
    ok "已创建 $ENTRY_MD_TARGET"
  fi

  rm -f "$section_file"

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
      workbuddy)   target="$HOME/.workbuddy/skills/investor-harness" ;;
      *) continue ;;
    esac
    if [ -L "$target" ] && [ -d "$target" ]; then
      ok "$harness skills 链接正常"
      # WorkBuddy 额外验证根目录 SKILL.md 存在（自动激活的必要条件）
      if [ "$harness" = "workbuddy" ] && [ -f "$target/SKILL.md" ]; then
        ok "  WorkBuddy 入口 SKILL.md 就绪（自动激活）"
      fi
    else
      err "$harness skills 链接缺失"
      errors=$((errors+1))
    fi
  done

  # 2. 入口 MD 注入
  if [ "$ENTRY_MD_TARGET" = "none" ]; then
    ok "WorkBuddy 模式：无需入口 MD（靠 SKILL.md 自动激活）"
  elif [ -f "$ENTRY_MD_TARGET" ] && grep -q "INVESTOR_HARNESS:BEGIN" "$ENTRY_MD_TARGET"; then
    ok "入口 MD 启用提示词已写入"
  else
    warn "入口 MD 启用提示词未检测到（可能你选择了跳过）"
  fi

  # 3. Workspace
  if [ -n "$WORKSPACE_ROOT" ] && [ -d "$WORKSPACE_ROOT" ]; then
    ok "工作区：$WORKSPACE_ROOT"
    [ -f "$WORKSPACE_ROOT/.task-pulse" ] && ok "  .task-pulse 存在" || warn "  .task-pulse 缺失"
    [ -d "$WORKSPACE_ROOT/.checkpoint" ] && ok "  .checkpoint/ 存在" || warn "  .checkpoint/ 缺失"
    [ -d "$WORKSPACE_ROOT/.supervision" ] && ok "  .supervision/ 存在" || warn "  .supervision/ 缺失（首次监工任务会自动创建）"
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
  if [ "$ENTRY_MD_TARGET" = "none" ]; then
    info "  WorkBuddy 入口:  $HOME/.workbuddy/skills/investor-harness/SKILL.md"
  else
    info "  启用提示词:     $ENTRY_MD_TARGET"
  fi
  echo
  info "下一步："
  info "  1. ${BOLD}重启你的 AI 工具${NC}（Claude Code / Codex / OpenClaw / WorkBuddy）"
  if [ -n "$WORKSPACE_ROOT" ]; then
    info "  2. cd ${WORKSPACE_ROOT}"
    info "  3. 随便问一家公司，比如：'看一下 LITE'"
    info "  4. 验证：LLM 应该先输出 [Preflight] 取数计划，而不是直接给百度百科段落"
  else
    info "  2. 随便问一家公司，比如：'看一下 LITE'"
    info "  3. 验证：LLM 应该先输出 [Preflight] 取数计划，而不是直接给百度百科段落"
  fi
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
  # 解析参数：--auto / --image 启用自动检测 harness 模式（图片驱动安装用）
  AUTO_MODE=0
  for arg in "$@"; do
    case "$arg" in
      --auto|--image)
        AUTO_MODE=1
        ;;
      --help|-h)
        echo "Usage: bash setup.sh [--auto]"
        echo "  --auto  自动检测 harness 类型，不询问用户（图片驱动安装 / NO_PROMPT 用）"
        echo "  也支持 NO_PROMPT=1 环境变量"
        exit 0
        ;;
    esac
  done
  export AUTO_MODE

  show_banner
  detect_environment
  select_harnesses
  select_data_sources
  install_skills
  create_workspace
  inject_entry_md
  verify_install
  show_completion
}

main "$@"
