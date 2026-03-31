# Browser Automator Scripts

Helper scripts để setup và manage browser automation trong OpenClaw.

## `setup-remote-cdp.sh` - Setup Remote Chrome CDP (Bash)

**Dùng khi:** Bạn có WSL2 + Windows + Chrome, cần setup kết nối lần đầu

**Chạy:**
```bash
./setup-remote-cdp.sh
```

**Tham số:**
- `[windows-host]` — IP/hostname của Windows (auto-detect nếu không cung cấp)
- `[port]` — Chrome CDP port, mặc định 9222
- `[config-file]` — Config file path, mặc định `.openclaw.json`

**Ví dụ:**
```bash
# Auto-detect tất cả
./setup-remote-cdp.sh

# Chỉ định host
./setup-remote-cdp.sh 172.17.48.1

# Chỉ định host + port
./setup-remote-cdp.sh 172.17.48.1 9223

# Chỉ định config file
./setup-remote-cdp.sh 172.17.48.1 9222 ~/.openclaw.json
```

**Những gì nó làm:**
1. Auto-detect Windows host từ WSL2 `/etc/resolv.conf`
2. Test kết nối tới Chrome CDP
3. Update `.openclaw.json` với `cdpUrl`
4. Verify connection bằng `/json/version`

---

## `setup-cdp.mjs` - Setup Remote Chrome CDP (Node.js)

**Dùng khi:** Bạn muốn dùng Node.js script thay vì bash

**Chạy:**
```bash
node setup-cdp.mjs
# hoặc
./setup-cdp.mjs
```

**Tính năng:**
- Auto-detect Windows host từ WSL2
- Test 3 host candidates: detected + `127.0.0.1` + `localhost`
- Pretty-printed output với colors
- Tự động config SSRF policy cho private network

**Output:**
```
✓ Detected Windows host: 172.17.48.1
✓ Connected!
✓ Saved config to .openclaw.json
✓ Connected to Chrome: Google Chrome/126.0.0.0
```

---

## Quick Decision Tree

| Situation | Use This |
|-----------|----------|
| WSL2 + Windows + Chrome | `setup-remote-cdp.sh` hoặc `setup-cdp.mjs` |
| Just need to update `.openclaw.json` | Edit file manually |
| Want to verify CDP connection | `curl http://WINDOWS_HOST:9222/json/version` |
| Need to debug network issues | Xem docs: https://docs.openclaw.ai/tools/browser-wsl2-windows-remote-cdp-troubleshooting |

---

## Manual Config (if scripts don't work)

Nếu scripts không thành công, edit `.openclaw.json`:

```json
{
  "browser": {
    "enabled": true,
    "cdpUrl": "http://WINDOWS_HOST:9222",
    "headless": false,
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true
    }
  }
}
```

Replace `WINDOWS_HOST` với:
- `127.0.0.1` — nếu trên Windows
- `172.17.48.1` — common WSL2 gateway
- `hostname.local` — nếu dùng mDNS

---

## Testing After Setup

```bash
# Check browser status
openclaw browser status

# Navigate to a page
openclaw browser navigate https://example.com

# Snapshot
openclaw browser snapshot --interactive

# Screenshot
openclaw browser screenshot --full-page
```

---

## Troubleshooting

### Script says "Cannot reach Chrome CDP"

1. **Chrome không chạy?**
   - Start Chrome với: `chrome.exe --remote-debugging-port=9222`

2. **Port sai?**
   - Kiểm tra Chrome port: `chrome://inspect`
   - Default là 9222, có thể thay đổi

3. **Firewall?**
   - Windows Defender có thể block
   - Thử cho phép port 9222 trong firewall

4. **WSL2 → Windows kết nối?**
   - Test từ WSL2: `curl http://172.17.48.1:9222/json/version`
   - Nếu fail, xem docs: https://docs.openclaw.ai/tools/browser-wsl2-windows-remote-cdp-troubleshooting

### Script found host nhưng OpenClaw vẫn không connect

1. Kiểm tra `.openclaw.json` có đúng `cdpUrl` không
2. Restart OpenClaw Gateway: `openclaw gateway restart`
3. Check status: `openclaw browser status`
4. Verify Chrome still running: `ps aux | grep chrome`

---

## Advanced: Custom Config

Nếu bạn muốn customize hơn, edit `.openclaw.json` sau khi script chạy:

```json
{
  "browser": {
    "enabled": true,
    "defaultProfile": "remote",
    "profiles": {
      "remote": {
        "cdpUrl": "http://172.17.48.1:9222",
        "attachOnly": true,
        "color": "#FF4500"
      }
    },
    "headless": false,
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true
    }
  }
}
```

Rồi dùng:
```bash
openclaw browser --browser-profile remote navigate https://example.com
```

---

## Support

- OpenClaw docs: https://docs.openclaw.ai
- Browser-WSL2-Windows troubleshooting: https://docs.openclaw.ai/tools/browser-wsl2-windows-remote-cdp-troubleshooting
- Issues: https://github.com/openclaw/openclaw/issues
