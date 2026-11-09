#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

command -v python3 >/dev/null || { echo "ERROR: Python 3 is required to host the web directory."; exit 1; }
mkdir -p web

if [[ -f web/web.pid ]] && kill -0 "$(cat web/web.pid)" 2>/dev/null; then
  echo "Web host is already running (PID $(cat web/web.pid))."
  exit 0
fi

rm -f web/web.pid
echo "Starting static web host on 0.0.0.0:8081..."
(
  cd "$ROOT"
  nohup python3 -m http.server 8081 --bind 0.0.0.0 --directory "$ROOT/web" > "$ROOT/web/web-console.log" 2>&1 &
  echo $! > "$ROOT/web/web.pid"
)

sleep 1
if ! kill -0 "$(cat web/web.pid)" 2>/dev/null; then
  echo "ERROR: Web host failed to start:"
  tail -n 40 web/web-console.log 2>/dev/null || true
  exit 1
fi

echo "Website: http://0.0.0.0:8081/"
echo "Codespaces: forward port 8081 and open its HTTPS URL."
