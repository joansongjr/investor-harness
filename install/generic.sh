#!/usr/bin/env bash
# Generic installer for any harness with a skills directory.
#
# Usage:
#   bash install/generic.sh /path/to/target/skills/dir            # symlink
#   bash install/generic.sh /path/to/target/skills/dir --copy     # copy

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: bash install/generic.sh /path/to/target/skills/dir [--copy]" >&2
  exit 1
fi

TARGET_DIR="$1"
MODE="${2:-}"
HARNESS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$TARGET_DIR"

TARGET="$TARGET_DIR/investor-harness"

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
echo "Restart your harness to pick up the new skills."
