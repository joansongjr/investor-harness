#!/usr/bin/env bash
# Investor Harness · workspace bootstrap
#
# Creates a structured analyst workspace from templates.
#
# Usage:
#   bash setup/bootstrap.sh ~/my-investor-workspace
#   bash setup/bootstrap.sh ~/my-investor-workspace --force   # overwrite existing files

set -euo pipefail

if [[ $# -lt 1 ]]; then
  cat <<EOF
Investor Harness · workspace bootstrap

Usage:
  bash setup/bootstrap.sh <target-dir> [--force]

This will create a new analyst workspace at <target-dir> with:
  - CLAUDE.md          (analyst persona + harness rules)
  - memory.md          (research memory index)
  - coverage.md        (covered companies)
  - watchlist.md       (companies you're watching)
  - decision-log.md    (investment decision journal)
  - research-queue.md  (research backlog)
  - biases.md          (your known biases)

Example:
  bash setup/bootstrap.sh ~/my-research
EOF
  exit 1
fi

TARGET_DIR="$1"
FORCE="${2:-}"
SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SETUP_DIR/workspace"
WORKSPACE_NAME="$(basename "$TARGET_DIR")"

mkdir -p "$TARGET_DIR"

FILES=(
  "CLAUDE.md"
  "memory.md"
  "coverage.md"
  "watchlist.md"
  "decision-log.md"
  "research-queue.md"
  "biases.md"
)

echo "Bootstrapping Investor Harness workspace at: $TARGET_DIR"
echo

CREATED=0
SKIPPED=0
OVERWRITTEN=0

for f in "${FILES[@]}"; do
  src="$TEMPLATE_DIR/${f}.template"
  dest="$TARGET_DIR/$f"

  if [[ ! -f "$src" ]]; then
    echo "  ! template missing: $src" >&2
    continue
  fi

  if [[ -f "$dest" && "$FORCE" != "--force" ]]; then
    echo "  - skip (exists): $f"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Substitute {WORKSPACE_NAME} placeholder
  sed "s/{WORKSPACE_NAME}/$WORKSPACE_NAME/g" "$src" > "$dest"

  if [[ "$FORCE" == "--force" && -f "$dest" ]]; then
    echo "  ✓ overwrote: $f"
    OVERWRITTEN=$((OVERWRITTEN + 1))
  else
    echo "  ✓ created:  $f"
    CREATED=$((CREATED + 1))
  fi
done

echo
echo "Summary: created=$CREATED, overwritten=$OVERWRITTEN, skipped=$SKIPPED"
echo
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Edit CLAUDE.md and fill in your role + coverage scope"
echo "  3. Edit memory.md and fill in your research identity"
echo "  4. Add your initial covered companies to coverage.md"
echo "  5. Open this folder in Claude Code / Codex / OpenCode and start asking:"
echo "       请用 sm-autopilot 看一下 [your-first-stock]"
echo
echo "Done."
