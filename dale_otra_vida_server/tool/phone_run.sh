#!/usr/bin/env bash
# Installs and runs the app on a USB-connected Android phone, pointing it at
# this Mac's current Wi-Fi IP. Start the server first (serverpod_start task).
set -euo pipefail
cd "$(dirname "$0")/../../dale_otra_vida_flutter"
lan_ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
if [[ -z "$lan_ip" ]]; then
  echo "✗ El Mac no está conectado a una red Wi-Fi; el celular no podría llegar al servidor."
  exit 1
fi
echo "✓ El celular usará http://$lan_ip:8080 (deben estar en la misma red Wi-Fi)"
exec flutter run --dart-define=SERVER_URL="http://$lan_ip:8080/"
