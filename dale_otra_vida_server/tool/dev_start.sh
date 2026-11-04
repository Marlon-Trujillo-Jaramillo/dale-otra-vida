#!/usr/bin/env bash
# Starts the local stack (database, server, web app) with the checks whose
# absence made VS Code launches fail without a clear reason. Used by the
# `serverpod_start` VS Code task; also works from a plain terminal.
set -euo pipefail
cd "$(dirname "$0")/.."

# 1. The Serverpod CLI lives in ~/.pub-cache/bin, which VS Code's PATH lacks.
if ! command -v serverpod >/dev/null 2>&1; then
  if [[ -x "$HOME/.pub-cache/bin/serverpod" ]]; then
    export PATH="$HOME/.pub-cache/bin:$PATH"
  else
    echo "✗ Falta el CLI de Serverpod. Instálalo con: dart pub global activate serverpod_cli"
    exit 1
  fi
fi

# 2. A second server cannot start while another one holds the ports.
for port in 8080 8090; do
  if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    owner="$(lsof -nP -iTCP:"$port" -sTCP:LISTEN | awk 'NR==2 {print $1 " (pid " $2 ")"}')"
    echo "✗ El puerto $port ya está en uso por $owner."
    echo "  Hay otro servidor o web corriendo (otra terminal o una sesión anterior)."
    echo "  Ciérralo con Ctrl+C en esa terminal, o ejecuta: kill ${owner##*pid }" | tr -d ')'
    exit 1
  fi
done

# 3. Photo URLs must use an address that works today: the Mac's current
#    Wi-Fi IP (it changes with the network), or localhost when offline.
lan_ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
export SERVERPOD_API_SERVER_PUBLIC_HOST="${lan_ip:-localhost}"
echo "✓ Fotos y subidas en http://${SERVERPOD_API_SERVER_PUBLIC_HOST}:8080"

exec serverpod start
