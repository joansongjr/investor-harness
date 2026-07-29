#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <workspace> <task-id> [checkpoint|Nm] [on|off]" >&2
}

if [[ $# -lt 2 || $# -gt 4 ]]; then
  usage
  exit 2
fi

WORKSPACE_DIR="$1"
TASK_ID="$2"
CADENCE="${3:-checkpoint}"
VOICE_MODE="${4:-off}"

if [[ ! -d "$WORKSPACE_DIR" ]]; then
  echo "Workspace does not exist: $WORKSPACE_DIR" >&2
  exit 1
fi

if [[ ! "$TASK_ID" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Invalid task-id: use letters, digits, dot, underscore, or hyphen" >&2
  exit 2
fi

if [[ "$CADENCE" != "checkpoint" && ! "$CADENCE" =~ ^[1-9][0-9]*m$ ]]; then
  echo "Invalid cadence: use checkpoint or Nm (for example, 5m)" >&2
  exit 2
fi

if [[ "$VOICE_MODE" != "on" && "$VOICE_MODE" != "off" ]]; then
  echo "Invalid voice mode: use on or off" >&2
  exit 2
fi

WORKSPACE_DIR="$(cd "$WORKSPACE_DIR" && pwd)"
SUPERVISION_ROOT="$WORKSPACE_DIR/.supervision"
CHANNEL_DIR="$SUPERVISION_ROOT/$TASK_ID"
INDEX_FILE="$SUPERVISION_ROOT/$TASK_ID.md"
STATE_FILE="$CHANNEL_DIR/state.json"
STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p "$CHANNEL_DIR/to-worker" "$CHANNEL_DIR/to-supervisor"

if [[ ! -f "$INDEX_FILE" ]]; then
  printf '%s\n' \
    "# 监督工单 · $TASK_ID" \
    "" \
    "- protocol: 1.1" \
    "- started_at: $STARTED_AT" \
    "- cadence: $CADENCE" \
    "- voice_mode: $VOICE_MODE" \
    "" \
    "## 巡检记录" \
    "" \
    "## 干预索引" \
    "" \
    "## 监工总结" \
    "" > "$INDEX_FILE"
fi

if [[ ! -f "$STATE_FILE" ]]; then
  if [[ "$VOICE_MODE" == "on" ]]; then
    VOICE_JSON="true"
  else
    VOICE_JSON="false"
  fi

  printf '%s\n' \
    '{' \
    '  "protocol": "1.1",' \
    "  \"task_id\": \"$TASK_ID\"," \
    '  "status": "waiting",' \
    "  \"voice_mode\": $VOICE_JSON," \
    "  \"cadence\": \"$CADENCE\"," \
    '  "last_seen_step": null,' \
    '  "last_checked_at": null' \
    '}' > "$STATE_FILE"
fi

printf '%s\n' \
  "supervision_ready" \
  "index=$INDEX_FILE" \
  "state=$STATE_FILE" \
  "to_worker=$CHANNEL_DIR/to-worker" \
  "to_supervisor=$CHANNEL_DIR/to-supervisor"
