#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stop_one() {
  local label="$1" dir="$2" pidfile="$3"
  local file="$ROOT/$dir/$pidfile"
  [[ -f "$file" ]] || { echo "$label is not running (no PID file)."; return 0; }
  local pid
  pid="$(cat "$file")"
  if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
    echo "Stopping $label (PID $pid)..."
    kill "$pid"
    for _ in {1..20}; do
      kill -0 "$pid" 2>/dev/null || break
      sleep 1
    done
    if kill -0 "$pid" 2>/dev/null; then
      echo "$label did not stop within 20 seconds; leaving it running."
      return 1
    fi
  fi
  rm -f "$file"
}
# Stop the proxy first so no new connections enter while Paper shuts down.
stop_one "Website" "pids" "web.pid"
stop_one "Velocity" "proxy" "velocity.pid"
stop_one "Paper" "server" "paper.pid"
