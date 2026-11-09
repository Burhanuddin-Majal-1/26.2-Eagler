#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/install-eaglerxserver.sh
CONFIG="$(find proxy/plugins -type f -iname 'listeners.toml' -print -quit 2>/dev/null || true)"

if [[ -z "$CONFIG" ]]; then
  echo "First run: starting the servers once so EaglerXServer can create its config..."
  ./scripts/start.sh
  for _ in {1..30}; do
    CONFIG="$(find proxy/plugins -type f -iname 'listeners.toml' -print -quit 2>/dev/null || true)"
    [[ -n "$CONFIG" ]] && break
    sleep 2
  done
  if [[ -z "$CONFIG" ]]; then
    echo "ERROR: listeners.toml was not generated. Velocity log:"
    tail -n 80 proxy/velocity-console.log 2>/dev/null || true
    ./scripts/stop.sh || true
    exit 1
  fi
  ./scripts/stop.sh
fi

./scripts/configure-bridge.sh
./scripts/start.sh
echo
echo "Bridge startup requested."
echo "Eagler WebSocket: port 8082"
echo "Java Edition:     port 25565"
echo "Paper backend:    127.0.0.1:25566 (keep private)"
