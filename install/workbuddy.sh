#!/usr/bin/env bash
# Install investor-harness into WorkBuddy (~/.workbuddy/skills/)
#
# WorkBuddy 与 Claude Code/Codex 的关键差异：
#   - 不写入口 MD（不读 ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md）
#   - 靠 harness 根目录的 SKILL.md 让 WorkBuddy 自动识别为 skill
#   - 安装即激活：symlink 到 ~/.workbuddy/skills/investor-harness 后，WorkBuddy
#     扫描到 investor-harness/SKILL.md 就会按 description 自动触发
#
# Usage:
#   bash install/workbuddy.sh            # symlink (dev-friendly, auto-update)
#   bash install/workbuddy.sh --copy     # copy files (stable, no dependency on source path)

set -euo pipefail

MODE="${1:-}"
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKBUDDY_SKILLS_DIR="${WORKBUDDY_SKILLS_DIR:-$HOME/.workbuddy/skills}"

# WorkBuddy 用户级目录可能还不存在（首次安装），主动创建
mkdir -p "$WORKBUDDY_SKILLS_DIR"

TARGET="$WORKBUDDY_SKILLS_DIR/investor-harness"

if [[ -e "$TARGET" && ! -L "$TARGET" ]]; then
  echo "Error: $TARGET exists and is not a symlink. Remove it first." >&2
  exit 1
fi

if [[ "$MODE" == "--copy" ]]; then
  rm -rf "$TARGET"
  cp -R "$HARNESS_DIR" "$TARGET"
  echo "Copied harness to $TARGET"
else
  rm -f "$TARGET"
  ln -s "$HARNESS_DIR" "$TARGET"
  echo "Linked $TARGET -> $HARNESS_DIR"
fi

echo
echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ Investor Harness installed for WorkBuddy"
echo "═══════════════════════════════════════════════════════════════"
echo
echo "  安装即激活——WorkBuddy 会扫描到："
echo "    📋 $TARGET/SKILL.md"
echo "  并按其 description 自动触发（投研任务 + onboarding 引导）。"
echo
echo "  ⚠️  不需要写入口 MD：WorkBuddy 不读 CLAUDE.md / AGENTS.md，"
echo "     靠根目录 SKILL.md 的 frontmatter description 做关键词匹配。"
echo
echo "  可选增强（持久路由底座）："
echo "    在 WorkBuddy 里说："
echo "      跑一下 investor-harness onboarding"
echo "    会引导你把路由表写入 ~/.workbuddy/MEMORY.md（用户级）"
echo "    或 {workspace}/.workbuddy/memory/MEMORY.md（项目级）"
echo
echo "  下一步："
echo "  1. 重启 WorkBuddy 会话（让 skill 扫描生效）"
echo "  2. 测试：说'看看 NVDA'，agent 应自动按 sm-autopilot 工作"
echo "  3. (可选) 说'跑一下 investor-harness onboarding'补建工作区骨架"
echo
echo "═══════════════════════════════════════════════════════════════"
