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
echo "Install complete."
echo "Skills available as:"
for s in "${SKILLS[@]}"; do
  echo "  - $s"
done
echo
echo "Restart Claude Code to pick up the new skills."
