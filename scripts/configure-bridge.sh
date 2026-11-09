#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$ROOT/proxy/plugins"
command -v python3 >/dev/null || { echo "ERROR: python3 is required"; exit 1; }
CONFIG="$(find "$PLUGIN_DIR" -type f \( -iname 'listeners.yaml' -o -iname 'listeners.yml' \) -print -quit 2>/dev/null || true)"
if [[ -z "$CONFIG" ]]; then
  echo "ERROR: EaglerXServer has not generated listeners.yaml yet."
  echo "Run ./scripts/start.sh once, wait for Velocity to finish loading, then ./scripts/stop.sh."
  exit 1
fi
python3 - "$CONFIG" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
if re.search(r'(?m)^\s*-\s*listener_name:\s*eaglercraft-8082\s*$', s):
    print("Port 8082 listener is already configured.")
    raise SystemExit(0)
m = re.search(r'(?m)^listener_list:\s*(?:\[\s*\])?\s*(?:#.*)?$', s)
if not m:
    raise SystemExit("ERROR: Could not find the listener_list YAML key; left the config unchanged.")
entry = (
    "\n  - listener_name: eaglercraft-8082"
    "\n    inject_address: \"0.0.0.0:8082\""
    "\n    velocity_clone_listener: true"
    "\n    dual_stack: true"
)
head, tail = s[:m.start()], s[m.end():]
if "[]" in m.group(0):
    s = head + "listener_list:" + entry + tail
else:
    next_key = re.search(r'(?m)^[A-Za-z0-9_-]+\s*:', tail)
    if next_key:
        pos = m.end() + next_key.start()
        s = s[:pos].rstrip() + entry + "\n" + s[pos:]
    else:
        s = s.rstrip() + entry + "\n"
p.write_text(s, encoding="utf-8")
print(f"Configured EaglerXServer listener in {p}")
PY
