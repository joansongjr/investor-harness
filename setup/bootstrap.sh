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
  - active-tasks.md    (in-progress task state, v0.3+)

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
  "active-tasks.md"
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

# v0.4: create .task-pulse and .checkpoint/ for task persistence
PULSE_FILE="$TARGET_DIR/.task-pulse"
if [[ ! -f "$PULSE_FILE" ]]; then
  cat > "$PULSE_FILE" <<'PULSE_EOF'
{"v":"0.4","ts":null,"tasks":[],"compacted":false,"warn":null}
PULSE_EOF
  echo "  ✓ created:  .task-pulse (task heartbeat, < 100 tokens)"
fi

CKPT_DIR="$TARGET_DIR/.checkpoint"
if [[ ! -d "$CKPT_DIR" ]]; then
  mkdir -p "$CKPT_DIR"
  echo "  ✓ created:  .checkpoint/ (resume directory)"
fi

# v0.7: create user-templates/ and user-skills/ for task permanence
USER_TEMPLATES_DIR="$TARGET_DIR/user-templates"
USER_SKILLS_DIR="$TARGET_DIR/user-skills"

if [[ ! -d "$USER_TEMPLATES_DIR" ]]; then
  mkdir -p "$USER_TEMPLATES_DIR"
  echo "  ✓ created:  user-templates/ (L1 任务模板目录)"
  # Copy 3 example templates
  for t in daily-briefing weekly-coverage-review monthly-pm-report; do
    src="$TEMPLATE_DIR/user-templates/${t}.md.template"
    dest="$USER_TEMPLATES_DIR/${t}.md"
    if [[ -f "$src" && ! -f "$dest" ]]; then
      cp "$src" "$dest"
      echo "    ✓ example:  user-templates/${t}.md"
    fi
  done
fi

if [[ ! -d "$USER_SKILLS_DIR" ]]; then
  mkdir -p "$USER_SKILLS_DIR"
  echo "  ✓ created:  user-skills/ (L2 继承 + L3 自创 skill 目录)"
  # Copy 2 example skills
  for s in my-deepdive-esg my-hk-ipo-analysis; do
    src="$TEMPLATE_DIR/user-skills/${s}/SKILL.md.template"
    dest_dir="$USER_SKILLS_DIR/${s}"
    dest="$dest_dir/SKILL.md"
    if [[ -f "$src" && ! -f "$dest" ]]; then
      mkdir -p "$dest_dir"
      cp "$src" "$dest"
      echo "    ✓ example:  user-skills/${s}/SKILL.md"
    fi
  done
fi

echo
echo "Summary: created=$CREATED, overwritten=$OVERWRITTEN, skipped=$SKIPPED"
echo
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Edit CLAUDE.md and fill in your role + coverage scope"
echo "  3. Edit memory.md and fill in your research identity"
echo "  4. Add your initial covered companies to coverage.md"
echo "  5. (可选) 改 user-templates/daily-briefing.md 为你自己的日报模板"
echo "  6. (可选) 把 user-skills/my-hk-ipo-analysis 改成你自己的定制 skill"
echo "  7. 打开此目录，在 Claude Code / Codex / OpenCode 里开始提问："
echo "       看一下 LITE"
echo "       跑一下日报"
echo
echo "Done."
