#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$ROOT/proxy/plugins"
CONFIG="$(find "$PLUGIN_DIR" -type f -iname 'listeners.toml' -print -quit 2>/dev/null || true)"

if [[ -z "$CONFIG" ]]; then
  echo "ERROR: EaglerXServer listeners.toml was not found under $PLUGIN_DIR."
  echo "Start Velocity once so EaglerXServer can generate its configuration."
  exit 1
fi

python3 - "$CONFIG" <<'PY'
from pathlib import Path
import re, sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

def replace_once(pattern, replacement, label):
    global text
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"ERROR: Could not locate {label}; config was not changed.")
    text = updated

replace_once(r'^(\s*inject_address\s*=\s*)".*?"\s*$',
             r'\g<1>"0.0.0.0:8082"', "inject_address")
replace_once(r'^(\s*velocity_clone_listener\s*=\s*)(?:true|false)\s*$',
             r'\g<1>true', "velocity_clone_listener")

if not re.search(r'(?m)^\s*dual_stack\s*=\s*true\s*$', text):
    raise SystemExit("ERROR: dual_stack is not enabled; config was not changed.")

path.write_text(text, encoding="utf-8")
print(f"Configured EaglerXServer WebSocket listener on 0.0.0.0:8082 in {path}")
PY
