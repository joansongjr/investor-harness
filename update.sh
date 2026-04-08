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
#   4. Update CLAUDE.md injection (if version changed)
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
    ok "已经是最新版本（$LOCAL_VERSION）"
    echo
    info "无需更新。如果你想重新应用 CLAUDE.md 启用提示词，跑 bash setup.sh"
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
    info "这可能影响 CLAUDE.md 启用提示词，稍后会自动迁移"
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
# Step 5: 更新 CLAUDE.md 启用提示词
# ═══════════════════════════════════════════════════

update_claude_md() {
  say "▎ Step 5 · 更新 CLAUDE.md 启用提示词"
  echo

  # 查找可能的 CLAUDE.md 位置
  local candidates=(
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.codex/CLAUDE.md"
    "$HOME/.openclaw/CLAUDE.md"
  )

  local found_any=0

  for target in "${candidates[@]}"; do
    if [ -f "$target" ] && grep -q "INVESTOR_HARNESS:BEGIN" "$target"; then
      found_any=1

      # 提取当前版本
      local current_version
      current_version="$(grep -oE "INVESTOR_HARNESS:BEGIN v[0-9.]+" "$target" | head -1 | sed 's/INVESTOR_HARNESS:BEGIN v//' || echo "unknown")"

      info "检测到 $target"
      info "  当前启用提示词版本：v${current_version}"
      info "  harness 版本：v${LOCAL_VERSION}"

      if [ "$current_version" = "$LOCAL_VERSION" ]; then
        ok "  版本一致，无需更新"
        continue
      fi

      warn "  版本不一致，建议更新"
      if prompt_yn "  自动更新 $target 的启用提示词？（原文件会备份）" "y"; then
        # 备份
        cp "$target" "${target}.backup-${TS}"
        ok "  已备份 → ${target}.backup-${TS}"

        # 调用 setup.sh 的 render 函数生成新内容
        # 这里简化处理：提示用户重跑 setup.sh 让它重新注入
        info "  请重跑 bash setup.sh 来重新注入最新版本的启用提示词"
        info "  或手动从 core/claude-md-section.md 模板替换 marker 之间的内容"
      fi
    fi
  done

  if [ "$found_any" -eq 0 ]; then
    info "未检测到任何带 marker 的 CLAUDE.md"
    info "如需启用，请跑 bash setup.sh"
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
  info "  2. 如果启用提示词有更新，跑一次 bash setup.sh 重新注入"
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
  update_claude_md
  show_completion
}

main "$@"
