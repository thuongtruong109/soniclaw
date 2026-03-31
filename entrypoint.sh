#!/bin/sh
set -e

detect_windows_ip() {
    for i in $(seq 1 10); do
        IP=$(getent hosts host.docker.internal 2>/dev/null | awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
        if [ -n "$IP" ]; then
            echo "[INFO] Detected Windows IP: $IP" >&2
            echo "$IP"
            return
        fi
        echo "[INFO] Waiting for Windows host IPv4... ($i/10)" >&2
        sleep 1
    done
    echo "[WARN] Cannot detect Windows IPv4, using host.docker.internal" >&2
    echo "host.docker.internal"
}

WINDOWS_IP=$(detect_windows_ip)
CDP_URL="http://$WINDOWS_IP:9222"

mkdir -p /root/.openclaw

if [ -f /root/.openclaw/openclaw.json ]; then
    jq --arg url "$CDP_URL" \
       '.browser.cdpUrl = $url | .browser.profiles.remote.cdpUrl = $url | .browser.enabled = true' \
       /root/.openclaw/openclaw.json > /root/.openclaw/openclaw.tmp.json
    mv /root/.openclaw/openclaw.tmp.json /root/.openclaw/openclaw.json
else
    cat > /root/.openclaw/openclaw.json <<EOF
{
  "browser": {
    "enabled": true,
    "cdpUrl": "$CDP_URL",
    "defaultProfile": "remote",
    "headless": false,
    "noSandbox": true,
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true
    },
    "profiles": {
      "remote": {
        "cdpUrl": "$CDP_URL",
        "color": "#Ff0000"
      }
    }
  }
}
EOF
fi

if ! command -v openclaw >/dev/null 2>&1; then
    curl -fsSL https://openclaw.ai/install.sh | bash
fi

echo "[INFO] Starting SSH server..." >&2
/usr/sbin/sshd

echo "[INFO] Starting OpenClaw browser..." >&2
openclaw browser start

echo "[INFO] Container ready. OpenClaw automation active." >&2
tail -f /dev/null