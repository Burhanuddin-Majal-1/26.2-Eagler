#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for bin in java; do
  command -v "$bin" >/dev/null || { echo "ERROR: Java is required"; exit 1; }
done
[[ -s server/paper.jar ]] || { echo "ERROR: server/paper.jar is missing"; exit 1; }
[[ -s proxy/velocity.jar ]] || { echo "ERROR: proxy/velocity.jar is missing"; exit 1; }
[[ -s proxy/plugins/EaglerXServer.jar ]] || ./scripts/install-eaglerxserver.sh

if [[ ! -f proxy/velocity.toml ]]; then
  cp proxy/velocity.toml.example proxy/velocity.toml
  echo "Created proxy/velocity.toml from the example."
fi
if [[ ! -f server/eula.txt ]] || ! grep -q '^eula=true$' server/eula.txt; then
  echo "ERROR: Review the Minecraft EULA and set eula=true in server/eula.txt before starting."
  exit 1
fi

mkdir -p server proxy
if [[ -f server/paper.pid ]] && kill -0 "$(cat server/paper.pid)" 2>/dev/null; then
  echo "Paper is already running (PID $(cat server/paper.pid))."
else
  rm -f server/paper.pid
  echo "Starting Paper backend on 127.0.0.1:25566..."
  (cd server && nohup java -Xms512M -Xmx2G -jar paper.jar --nogui > paper-console.log 2>&1 & echo $! > paper.pid)
fi

for attempt in {1..60}; do
  if grep -q 'Done (' server/paper-console.log 2>/dev/null; then break; fi
  if ! kill -0 "$(cat server/paper.pid 2>/dev/null || echo 0)" 2>/dev/null; then
    echo "ERROR: Paper exited during startup. Last log lines:"
    tail -n 60 server/paper-console.log 2>/dev/null || true
    exit 1
  fi
  sleep 2
done

if [[ -f proxy/velocity.pid ]] && kill -0 "$(cat proxy/velocity.pid)" 2>/dev/null; then
  echo "Velocity is already running (PID $(cat proxy/velocity.pid))."
else
  rm -f proxy/velocity.pid
  echo "Starting Velocity proxy on 0.0.0.0:25565..."
  (cd proxy && nohup java -Xms256M -Xmx1G -jar velocity.jar > velocity-console.log 2>&1 & echo $! > velocity.pid)
fi

sleep 3
if ! kill -0 "$(cat proxy/velocity.pid 2>/dev/null || echo 0)" 2>/dev/null; then
  echo "ERROR: Velocity exited. Last log lines:"
  tail -n 80 proxy/velocity-console.log 2>/dev/null || true
  exit 1
fi

echo
echo "Paper backend: 127.0.0.1:25566"
echo "Velocity Java:  0.0.0.0:25565"
echo "Eagler WebSocket listener will be configured on 0.0.0.0:8082."
echo "Logs: server/paper-console.log and proxy/velocity-console.log"
