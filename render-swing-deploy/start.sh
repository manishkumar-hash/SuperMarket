#!/usr/bin/env bash
set -euo pipefail

: "${PORT:=10000}"
if [[ -z "${VNC_PASSWORD:-}" || ${#VNC_PASSWORD} -lt 6 ]]; then
  echo "ERROR: Set VNC_PASSWORD in Render (at least 6 characters)." >&2
  exit 1
fi

# Keep the Java program's expected relative CSV paths while storing data
# on Render's persistent disk mounted at /var/data.
for file in products.csv sales.csv; do
  if [[ ! -f "/var/data/$file" ]]; then
    cp "/app/$file" "/var/data/$file"
  fi
  ln -sf "/var/data/$file" "/app/$file"
done

mkdir -p /tmp/.X11-unix
Xvfb "$DISPLAY" -screen 0 1366x850x24 -ac +extension RANDR -nolisten tcp &
sleep 2
fluxbox >/tmp/fluxbox.log 2>&1 &
x11vnc -storepasswd "$VNC_PASSWORD" /tmp/vnc.pass >/dev/null
x11vnc -display "$DISPLAY" -forever -shared -rfbauth /tmp/vnc.pass \
  -rfbport 5900 -localhost -quiet >/tmp/x11vnc.log 2>&1 &
sleep 2

# Launch the original Swing application; no source-code changes are made.
cd /app
java -cp /app SupermarketSystem >/tmp/supermarket.log 2>&1 &
JAVA_PID=$!

# Render forwards the public HTTP/WebSocket port to this noVNC endpoint.
websockify --web=/usr/share/novnc --heartbeat=30 "$PORT" 127.0.0.1:5900 &
PROXY_PID=$!

cleanup() {
  kill "$PROXY_PID" "$JAVA_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM
wait "$PROXY_PID"
