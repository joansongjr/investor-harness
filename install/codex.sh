#!/usr/bin/env bash
# Install investor-harness into Codex (~/.codex/skills/)

set -euo pipefail

MODE="${1:-}"
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CODEX_SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

mkdir -p "$CODEX_SKILLS_DIR"

TARGET="$CODEX_SKILLS_DIR/investor-harness"

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
echo "  ✅ Investor Harness installed (28 skills)"
echo "═══════════════════════════════════════════════════════════════"
echo
echo "  推荐下一步（v0.9.2）："
echo "  1. 重启 Codex"
echo "  2. 在 Codex 里说："
echo "       跑一下 investor-harness onboarding"
echo "  3. 它会引导你把路由写到："
echo "       📋 ~/.codex/AGENTS.md"
echo
echo "  手动说明：cat $HARNESS_DIR/INSTALL-PROMPT.md"
echo
echo "  否则 LLM 不会自动按 Investor Harness 流程工作。"
echo "═══════════════════════════════════════════════════════════════"
