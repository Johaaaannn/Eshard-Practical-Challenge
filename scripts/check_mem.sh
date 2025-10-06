#!/usr/bin/env bash
set -euo pipefail
LOG_DIR="/var/log/websvc"
LOG_FILE="$LOG_DIR/mem_alert.log"
THRESHOLD=70

mkdir -p "$LOG_DIR"

read -r t a < <(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {print t, a}' /proc/meminfo)
used=$((t - a))
pct=$((100 * used / t))
ts="$(date -Is)"

if (( pct >= THRESHOLD )); then
  echo "$ts ALERT: Memory usage ${pct}% >= ${THRESHOLD}% on $(hostname)" >> "$LOG_FILE"
else
  echo "$ts OK: Memory usage ${pct}% < ${THRESHOLD}%" >> "$LOG_FILE"
fi
