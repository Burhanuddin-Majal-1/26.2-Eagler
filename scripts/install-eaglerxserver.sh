#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$ROOT/proxy/plugins"
JAR="$PLUGIN_DIR/EaglerXServer.jar"
URL="https://github.com/lax1dude/eaglerxserver/releases/download/v1.1.1/EaglerXServer.jar"
SHA256="468cb07eb7ca466b21b439be75156d3d01579327f4c6dae5b67d471137a64208"

command -v curl >/dev/null || { echo "ERROR: curl is required"; exit 1; }
command -v sha256sum >/dev/null || { echo "ERROR: sha256sum is required"; exit 1; }
mkdir -p "$PLUGIN_DIR"

if [[ -s "$JAR" ]] && echo "$SHA256  $JAR" | sha256sum -c - >/dev/null 2>&1; then
  echo "EaglerXServer 1.1.1 is already installed."
  exit 0
fi

echo "Downloading official EaglerXServer 1.1.1..."
TMP="$JAR.tmp"
curl -fL --retry 3 "$URL" -o "$TMP"
echo "$SHA256  $TMP" | sha256sum -c -
mv "$TMP" "$JAR"
echo "Installed: $JAR"
