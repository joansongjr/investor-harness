#!/usr/bin/env bash
#
# Investor Harness · Update Wizard
# https://github.com/joansongjr/investor-harness
#
# Usage:
#   bash update.sh
#
# What it does:
#   1. Check current version vs remote latest
#   2. git pull
#   3. Detect breaking changes
#   4. Update managed entrypoint MD blocks (if version changed)
#   5. Show changelog
#   6. Verify

set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_VERSION="$(cat "$HARNESS_DIR/VERSION" 2>/dev/null || echo "unknown")"
TS="$(date +%Y%m%d-%H%M%S)"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
NC=$'\033[0m'

say() { echo "${BOLD}$*${NC}"; }
info() { echo "  ${BLUE}ℹ${NC} $*"; }
ok() { echo "  ${GREEN}✓${NC} $*"; }
warn() { echo "  ${YELLOW}⚠${NC} $*"; }
err() { echo "  ${RED}✗${NC} $*" >&2; }
hr() { echo "════════════════════════════════════════════════════════════"; }

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

build_data_sources_chain() {
  local data_sources="$1"
  local chain=""
  local normalized=" $data_sources "
  local idx=1

  chain="${chain}**A 股 / 公募 (CN-A / CN-FUND)**:\n"
  [[ "$normalized" == *" ifind "* ]] && { chain="${chain}  $idx. iFind MCP (get_stock_summary / get_stock_financials / search_stocks 等)\n"; idx=$((idx+1)); }
  [[ "$normalized" == *" alphapie "* ]] && { chain="${chain}  $idx. Alpha派 MCP (补充 / 互验)\n"; idx=$((idx+1)); }
  [[ "$normalized" == *" wind "* ]] && { chain="${chain}  $idx. Wind MCP (高质量财务数据)\n"; idx=$((idx+1)); }
  [[ "$normalized" == *" jinmen "* ]] && { chain="${chain}  $idx. 进门财经 MCP (路演 / 专家 / 研报)\n"; idx=$((idx+1)); }
  [[ "$normalized" == *" cn-web-search "* ]] && { chain="${chain}  $idx. cn-web-search skill\n"; idx=$((idx+1)); }
  [[ "$normalized" == *" websearch "* ]] && { chain="${chain}  $idx. WebSearch（兜底）\n"; idx=$((idx+1)); }
  chain="${chain}  $idx. 用户手动贴材料\n"

  chain="${chain}\n**港股 / 美股 / 跨市场**:\n"
  idx=1
  [[ "$normalized" == *" wind "* ]] && { chain="${chain}  $idx. Wind MCP (全球覆盖)\n"; idx=$((idx+1)); }
  [[ "$normalized" == *" websearch "* ]] && { chain="${chain}  $idx. WebSearch (SEC EDGAR / HKEX)\n"; idx=$((idx+1)); }
  chain="${chain}  $idx. 用户手动贴材料\n"

  printf "%b" "$chain"
}

render_legacy_entry_section() {
  local workspace_root="$1"
  local data_sources="$2"
  local date_str chain data_sources_str coverage_root

  date_str="$(date +%Y-%m-%d)"
  data_sources="${data_sources:-websearch}"
  data_sources_str="$(echo "$data_sources" | xargs | tr ' ' ',')"
  chain="$(build_data_sources_chain "$data_sources")"
  coverage_root="${workspace_root}/coverage"

  cat <<EOF
<!-- INVESTOR_HARNESS:BEGIN v${LOCAL_VERSION} -->
<!-- DO NOT EDIT MANUALLY — managed by investor-harness setup.sh / update.sh -->

# Investor Harness · 投研工作纪律（自动注入，勿改）

**version**: v${LOCAL_VERSION}
**last_updated**: ${date_str}
**harness_path**: ${HARNESS_DIR}
**workspace_root**: ${workspace_root}
**data_sources**: ${data_sources_str}

## 启动协议（每次新会话第一件事）

1. 读 \`${HARNESS_DIR}/core/_boot.md\`（~1.2k tokens）
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
| "X 估值" / "X 贵不贵" / "X 怎么估" | 走 \`sm-valuation\` |
| "量化看盘" / "X 缠论" / "X 买卖点" | 走 \`sm-quant-tape\` |
| "盯盘" / "每小时看一下 X" / "X 盘中异动" | 走 \`sm-hourly-watch\` |
| "收盘后复盘" / "股票池复盘" | 走 \`sm-close-recap\` |
| "选股" / "筛标的" / "挖标的" | 走 \`sm-stock-screen\` |
| "监工 X" / "三方任务组" / "语音监工" | 走 \`sm-supervisor\` |
| "归纳提问" / "把这些问题学进去" / "看看学了什么" / "撤销 L-xxx" | 走 \`sm-learn\`（主要靠自动触发） |
| "起 X 的 wiki page" / "建 X 的 coverage" / "onboard X" | 走 \`sm-wiki-build\`（仅用户明示时） |
| "刷 daily feed" / "跑每日扫描" / "今天看一下覆盖池" | 走 \`sm-daily-feed\`（仅用户明示时） |
| "见 X 前过一遍 question list" / "准备 X 调研提纲" / "会前 briefing" | 走 \`sm-question-list\`（仅用户明示时） |
| "跑健康检查" / "扫跨源矛盾" / "wiki 自检" | 走 \`sm-health-check\`（仅用户明示时） |
| "会后归档" / "整理 X 的 Q&A" / "见完 X 后整理" | 走 \`sm-qa-archive\`（仅用户明示时） |
| "关键人物追踪" / "外网观点" / "跟踪 Reddit" | 走 \`sm-people-watch\`（仅用户明示时） |

## Skill 调用的强制流程

**开始前 Preamble 6 步**（读 \`${HARNESS_DIR}/core/preamble.md\`）：
0. 检查 .task-pulse 续跑
1. 识别市场
2. 检查历史输出
3. 检查 active-tasks
4. **必须**输出 \`[Preflight]\` 取数计划
5. 实际取数

**输出时**：按 skill 结构；每条事实带完整中文证据等级；风险必须可观测可触发。

**结束后 Postamble 8 步**（读 \`${HARNESS_DIR}/core/postamble.md\`）：
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

render_keyword_routes_block() {
  sed \
    -e "1s/v[0-9][0-9.]*/v${LOCAL_VERSION}/" \
    -e "s|INVESTOR_HARNESS_PATH|$HARNESS_DIR|g" \
    "$HARNESS_DIR/setup/routes-block.template.md"
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
  echo "  ${BOLD}Investor Harness · 更新向导${NC}"
  echo "  本地版本: v${LOCAL_VERSION}"
  hr
  echo
}

# ═══════════════════════════════════════════════════
# Step 1: 检查是否为 git 仓库
# ═══════════════════════════════════════════════════

check_git_repo() {
  say "▎ Step 1 · 检查 git 状态"
  echo

  cd "$HARNESS_DIR"

  if [ ! -d ".git" ]; then
    err "$HARNESS_DIR 不是 git 仓库"
    info "如果你用 --copy 方式安装或手动解压安装，需要："
    info "  1. rm -rf $HARNESS_DIR"
    info "  2. git clone https://github.com/joansongjr/investor-harness.git $HARNESS_DIR"
    info "  3. bash setup.sh"
    exit 1
  fi

  ok "git 仓库：$(git remote get-url origin 2>/dev/null || echo '本地')"
  ok "当前分支：$(git branch --show-current)"
  echo
}

# ═══════════════════════════════════════════════════
# Step 2: 检查远程版本
# ═══════════════════════════════════════════════════

check_remote_version() {
  say "▎ Step 2 · 检查远程版本"
  echo

  cd "$HARNESS_DIR"

  info "正在从 origin 拉取最新信息..."
  git fetch origin main --quiet 2>/dev/null || { warn "git fetch 失败（可能网络问题）"; return 1; }

  local local_commit remote_commit
  local_commit="$(git rev-parse HEAD)"
  remote_commit="$(git rev-parse origin/main 2>/dev/null || echo "")"

  if [ -z "$remote_commit" ]; then
    warn "无法获取远程 commit"
    return 1
  fi

  if [ "$local_commit" = "$remote_commit" ]; then
    ok "已经是最新版本（${LOCAL_VERSION}）"
    echo
    info "无需更新。如果你想重新应用入口 MD 配置，跑 bash setup.sh 或重跑 onboarding"
    echo
    exit 0
  fi

  # 获取远程 VERSION 文件内容
  local remote_version
  remote_version="$(git show origin/main:VERSION 2>/dev/null || echo "unknown")"

  warn "发现新版本"
  info "  本地：v${LOCAL_VERSION}"
  info "  远程：v${remote_version}"
  echo

  # 显示新 commits
  info "新的提交："
  git log --oneline "$local_commit..$remote_commit" | head -10 | sed 's/^/    /'
  echo

  REMOTE_VERSION="$remote_version"
  LOCAL_COMMIT="$local_commit"
  REMOTE_COMMIT="$remote_commit"
}

# ═══════════════════════════════════════════════════
# Step 3: 检测破坏性变更
# ═══════════════════════════════════════════════════

detect_breaking_changes() {
  say "▎ Step 3 · 检测破坏性变更"
  echo

  cd "$HARNESS_DIR"

  local changed_files
  changed_files="$(git diff --name-only "$LOCAL_COMMIT" "$REMOTE_COMMIT" 2>/dev/null || echo "")"

  local breaking=0

  # 1. VERSION major bump
  local local_major remote_major
  local_major="$(echo "$LOCAL_VERSION" | cut -d. -f1)"
  remote_major="$(echo "$REMOTE_VERSION" | cut -d. -f1)"
  if [ "$local_major" != "$remote_major" ]; then
    warn "Major version bump: v${LOCAL_VERSION} → v${REMOTE_VERSION}"
    warn "主版本升级可能包含破坏性变更，务必查看完整 changelog"
    breaking=1
  fi

  # 2. Skills 重命名检测
  if echo "$changed_files" | grep -qE "skills/sm-[a-z-]+/SKILL\.md"; then
    local deleted_skills
    deleted_skills="$(git diff --diff-filter=D --name-only "$LOCAL_COMMIT" "$REMOTE_COMMIT" 2>/dev/null | grep "skills/" || true)"
    if [ -n "$deleted_skills" ]; then
      warn "有 skill 被删除或重命名："
      echo "$deleted_skills" | sed 's/^/    /'
      breaking=1
    fi
  fi

  # 3. core/ 关键文件变更
  if echo "$changed_files" | grep -qE "core/(preamble|postamble|_boot)\.md"; then
    info "core/ 流程文件有更新（preamble / postamble / _boot）"
    info "这可能影响入口 MD 注入块，稍后会自动迁移"
  fi

  # 4. bootstrap.sh / workspace 模板
  if echo "$changed_files" | grep -qE "(setup/bootstrap\.sh|setup/workspace/)"; then
    info "workspace 模板有更新（现有 workspace 不会自动迁移）"
  fi

  if [ "$breaking" -eq 1 ]; then
    echo
    warn "检测到破坏性变更"
    if ! prompt_yn "继续更新？（建议先查看 changelog）" "n"; then
      info "已取消。查看 changelog: https://github.com/joansongjr/investor-harness/releases"
      exit 0
    fi
  else
    ok "无破坏性变更"
  fi

  echo
}

# ═══════════════════════════════════════════════════
# Step 4: git pull
# ═══════════════════════════════════════════════════

do_git_pull() {
  say "▎ Step 4 · 拉取更新"
  echo

  cd "$HARNESS_DIR"

  # 检查工作区干净
  if [ -n "$(git status --porcelain)" ]; then
    warn "工作区有未提交的修改："
    git status --short | sed 's/^/    /'
    echo
    if ! prompt_yn "stash 本地修改并继续更新？" "y"; then
      info "已取消"
      exit 0
    fi
    git stash push -u -m "update.sh auto-stash ${TS}" >/dev/null
    ok "已 stash 到 stash@{0}"
    info "恢复：git stash pop"
  fi

  info "git pull origin main..."
  git pull origin main --ff-only 2>&1 | sed 's/^/    /'
  ok "拉取完成"

  LOCAL_VERSION="$(cat "$HARNESS_DIR/VERSION")"
  ok "新版本：v${LOCAL_VERSION}"
  echo
}

# ═══════════════════════════════════════════════════
# Step 5: 更新入口 MD 注入块
# ═══════════════════════════════════════════════════

update_entry_md() {
  say "▎ Step 5 · 更新入口 MD 注入块"
  echo

  # 查找可能的 managed entrypoint 位置
  local candidates=(
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.codex/AGENTS.md"
    "$HOME/.codex/CLAUDE.md"
    "$HOME/.config/opencode/AGENTS.md"
    "$HOME/.config/opencode/CLAUDE.md"
    "$HOME/.openclaw/CLAUDE.md"
  )

  local found_any=0

  for target in "${candidates[@]}"; do
    [ -f "$target" ] || continue

    if grep -q "investor-harness:keyword-routes:start" "$target"; then
      found_any=1

      local current_version route_file
      current_version="$(grep -oE "investor-harness:keyword-routes:start v[0-9.]+" "$target" | head -1 | sed 's/.* v//' || echo "unknown")"

      info "检测到 $target"
      info "  当前路由块版本：v${current_version}"
      info "  harness 版本：v${LOCAL_VERSION}"

      if [ "$current_version" = "$LOCAL_VERSION" ]; then
        ok "  版本一致，无需更新"
        continue
      fi

      warn "  版本不一致，建议更新"
      if prompt_yn "  自动更新 $target 的路由块？（原文件会备份）" "y"; then
        cp "$target" "${target}.backup-${TS}"
        ok "  已备份 → ${target}.backup-${TS}"

        route_file="$(mktemp "${TMPDIR:-/tmp}/investor-harness-routes.XXXXXX")"
        render_keyword_routes_block > "$route_file"
        replace_managed_block "$target" "^<!-- investor-harness:keyword-routes:start" "^<!-- investor-harness:keyword-routes:end -->$" "$route_file"
        rm -f "$route_file"
        ok "  已更新 onboarding 路由块"
      fi

      continue
    fi

    if grep -q "INVESTOR_HARNESS:BEGIN" "$target"; then
      found_any=1

      local current_version workspace_root data_sources_csv data_sources section_file
      current_version="$(grep -oE "INVESTOR_HARNESS:BEGIN v[0-9.]+" "$target" | head -1 | sed 's/INVESTOR_HARNESS:BEGIN v//' || echo "unknown")"
      workspace_root="$(awk -F': ' '/^\*\*workspace_root\*\*: /{print $2; exit}' "$target")"
      data_sources_csv="$(awk -F': ' '/^\*\*data_sources\*\*: /{print $2; exit}' "$target")"
      workspace_root="${workspace_root:-~/investor-research}"
      data_sources="${data_sources_csv//,/ }"
      data_sources="${data_sources:-websearch}"

      info "检测到 $target"
      info "  当前启用段版本：v${current_version}"
      info "  harness 版本：v${LOCAL_VERSION}"

      if [ "$current_version" = "$LOCAL_VERSION" ]; then
        ok "  版本一致，无需更新"
        continue
      fi

      warn "  版本不一致，建议更新"
      if prompt_yn "  自动更新 $target 的启用段？（原文件会备份）" "y"; then
        cp "$target" "${target}.backup-${TS}"
        ok "  已备份 → ${target}.backup-${TS}"

        section_file="$(mktemp "${TMPDIR:-/tmp}/investor-harness-section.XXXXXX")"
        render_legacy_entry_section "$workspace_root" "$data_sources" > "$section_file"
        replace_managed_block "$target" "^<!-- INVESTOR_HARNESS:BEGIN" "^<!-- INVESTOR_HARNESS:END -->$" "$section_file"
        rm -f "$section_file"
        ok "  已更新 setup.sh 管理的启用段"
      fi
    fi
  done

  if [ "$found_any" -eq 0 ]; then
    info "未检测到任何由 setup.sh 或 onboarding 管理的入口 MD"
    info "如需启用，请跑 bash setup.sh 或重跑 investor-harness onboarding"
  fi

  echo
}

# ═══════════════════════════════════════════════════
# Step 6: 完成
# ═══════════════════════════════════════════════════

show_completion() {
  echo
  hr
  say "  ✅ 更新完成"
  hr
  echo
  info "版本：v${LOCAL_VERSION}"
  info "位置：$HARNESS_DIR"
  echo
  info "下一步："
  info "  1. 重启你的 AI 工具（Claude Code / Codex / OpenClaw）"
  info "  2. 如果入口 MD 还有旧内容，重跑一次 onboarding 或 bash setup.sh"
  info "  3. 查看完整 changelog：https://github.com/joansongjr/investor-harness/releases/tag/v${LOCAL_VERSION}"
  echo
}

# ═══════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════

main() {
  show_banner
  check_git_repo
  check_remote_version
  detect_breaking_changes
  do_git_pull
  update_entry_md
  show_completion
}

main "$@"
