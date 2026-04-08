#!/usr/bin/env bash
# Install investor-harness into Claude Code (~/.claude/skills/)
#
# Usage:
#   bash install/claude-code.sh            # symlink (dev-friendly, auto-update)
#   bash install/claude-code.sh --copy     # copy files (stable, no dependency on source path)

set -euo pipefail

MODE="${1:-}"
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

SKILLS=(
  sm-master
  sm-autopilot
  sm-thesis
  sm-industry-map
  sm-company-deepdive
  sm-earnings-preview
  sm-model-check
  sm-consensus-watch
  sm-catalyst-monitor
  sm-roadshow-questions
  sm-red-team
  sm-pm-brief
  sm-briefing
  sm-tape-review
  sm-batch-refresh
  sm-batch-earnings
  sm-catalyst-sweep
)

mkdir -p "$CLAUDE_SKILLS_DIR"

# Note: skills reference ../../core/ relative paths. When we install individual
# skills into ~/.claude/skills/, we need the core/ alongside them.
# Solution: install the whole harness as one directory and symlink each skill out,
# OR copy the whole harness into a subdir and symlink.
#
# Simpler: put the harness in ~/.claude/skills/investor-harness/, and each skill
# is addressable as investor-harness/skills/sm-xxx. Claude Code picks these up.

TARGET="$CLAUDE_SKILLS_DIR/investor-harness"

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
echo "  ✅ Skills installed (17 total)"
echo "═══════════════════════════════════════════════════════════════"
for s in "${SKILLS[@]}"; do
  echo "  • $s"
done
echo
echo "═══════════════════════════════════════════════════════════════"
echo "  ⚠️  IMPORTANT · 关键最后一步"
echo "═══════════════════════════════════════════════════════════════"
echo
echo "  装好 skills **不等于** LLM 会自动遵守规则。"
echo "  你必须把 INSTALL-PROMPT.md 里的提示词复制到："
echo
echo "    📋 ~/.claude/CLAUDE.md  (推荐 — 全局生效)"
echo
echo "  否则 LLM 不会自动按 Investor Harness 流程工作。"
echo
echo "  完整说明 + 复制粘贴的提示词正文："
echo "    📖 $HARNESS_DIR/INSTALL-PROMPT.md"
echo
echo "  Quick start：先 cat 一下："
echo "    cat $HARNESS_DIR/INSTALL-PROMPT.md"
echo
echo "═══════════════════════════════════════════════════════════════"
echo "  下一步建议"
echo "═══════════════════════════════════════════════════════════════"
echo
echo "  1. 阅读 INSTALL-PROMPT.md 并把'启用提示词'贴到 ~/.claude/CLAUDE.md"
echo "  2. (可选) 跑 bash setup/bootstrap.sh ~/my-investor-workspace 创建工作区"
echo "  3. 重启 Claude Code"
echo "  4. 测试：'看一下 LITE'，应该看到 [Preflight] 段而不是百度百科"
echo
echo "═══════════════════════════════════════════════════════════════"
