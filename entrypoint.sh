#!/bin/sh
set -e

STATE_DIR=/root/.openclaw
SEED_DIR=/seed
ENV_FILE="$STATE_DIR/.env"

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

# Generate a Gateway token on first start instead of shipping a predictable one.
ensure_gateway_token() {
    current=$(sed -n 's/^GATEWAY_TOKEN=//p' "$ENV_FILE" 2>/dev/null | head -n 1)
    case "$current" in
        "" | "your-secret-gateway-token-here")
            token=$(od -An -N24 -tx1 /dev/urandom | tr -d ' \n')
            if [ -f "$ENV_FILE" ] && grep -q '^GATEWAY_TOKEN=' "$ENV_FILE"; then
                sed "s|^GATEWAY_TOKEN=.*|GATEWAY_TOKEN=$token|" "$ENV_FILE" > "$ENV_FILE.tmp"
                mv "$ENV_FILE.tmp" "$ENV_FILE"
            else
                printf 'GATEWAY_TOKEN=%s\n' "$token" >> "$ENV_FILE"
            fi
            echo "[INFO] Generated a new GATEWAY_TOKEN in $ENV_FILE" >&2
            ;;
    esac
}

mkdir -p "$STATE_DIR"

# First start: import the repo copy of .openclaw into the named volume.
# OpenClaw's atomic writes are not safe on Windows bind mounts, so the volume is
# the live state directory and $SEED_DIR is only a template.
if [ -d "$SEED_DIR" ] && [ ! -f "$STATE_DIR/openclaw.json" ]; then
    echo "[INFO] First start: importing state from $SEED_DIR" >&2
    for entry in "$SEED_DIR"/* "$SEED_DIR"/.env "$SEED_DIR"/.env.example; do
        [ -e "$entry" ] || continue
        case "$(basename "$entry")" in
            tmp) continue ;;
        esac
        cp -a "$entry" "$STATE_DIR/" 2>/dev/null || echo "[WARN] Could not import $(basename "$entry")" >&2
    done
fi

# A crashed doctor/gateway run can leave ownership locks behind. At container
# start nothing is running in $STATE_DIR, so every lock found here is stale.
find "$STATE_DIR/tmp" "$STATE_DIR/locks" -maxdepth 3 -name '*.lock' -delete 2>/dev/null || true

ensure_gateway_token

WINDOWS_IP=$(detect_windows_ip)
CDP_URL="http://$WINDOWS_IP:9222"

if [ -f "$STATE_DIR/openclaw.json" ]; then
    jq --arg url "$CDP_URL" \
       '.browser.profiles.remote.cdpUrl = $url' \
       "$STATE_DIR/openclaw.json" > "$STATE_DIR/openclaw.tmp.json"
    mv "$STATE_DIR/openclaw.tmp.json" "$STATE_DIR/openclaw.json"
else
    cat > "$STATE_DIR/openclaw.json" <<EOF
{
  "browser": {
    "enabled": true,
    "defaultProfile": "remote",
    "headless": false,
    "noSandbox": true,
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true
    },
    "profiles": {
      "remote": {
        "cdpUrl": "$CDP_URL"
      }
    }
  }
}
EOF
fi

# Doctor checks the sticky bit on the temp workspace ancestor.
chmod 1777 /tmp 2>/dev/null || true

# Verify openclaw binary is present (installed in image, not at runtime).
if ! command -v openclaw >/dev/null 2>&1; then
    echo "[ERROR] openclaw not found in image. Rebuild with the correct Dockerfile." >&2
    exit 1
fi

# Run doctor to migrate state and validate config before starting Gateway.
echo "[INFO] Running openclaw doctor..." >&2
openclaw doctor --fix --non-interactive || {
    echo "[ERROR] openclaw doctor --fix failed (exit $?). Check state manually." >&2
    exit 1
}

echo "[INFO] Starting gateway on port 18789..." >&2
exec openclaw gateway
