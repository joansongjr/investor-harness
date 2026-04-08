#!/usr/bin/env bash
# Install investor-harness into OpenCode (~/.config/opencode/skills/)
# Note: OpenCode's exact skills directory may vary; check docs if unsure.

set -euo pipefail

MODE="${1:-}"
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"

mkdir -p "$OPENCODE_SKILLS_DIR"

TARGET="$OPENCODE_SKILLS_DIR/investor-harness"

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
echo "  ✅ Investor Harness installed (17 skills)"
echo "═══════════════════════════════════════════════════════════════"
echo
echo "  ⚠️  关键最后一步："
echo "  把 INSTALL-PROMPT.md 里的'启用提示词'复制到："
echo "    📋 ~/.config/opencode/CLAUDE.md (或 OpenCode 的系统提示位置)"
echo
echo "  完整说明：cat $HARNESS_DIR/INSTALL-PROMPT.md"
echo
echo "  否则 LLM 不会自动按 Investor Harness 流程工作。"
echo
echo "  Restart OpenCode to pick up the new skills."
echo "═══════════════════════════════════════════════════════════════"
