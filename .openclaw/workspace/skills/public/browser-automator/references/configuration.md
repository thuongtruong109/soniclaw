# Browser Configuration Guide

Configure OpenClaw browser behavior via `~/.openclaw/openclaw.json`.

## Quick Configuration

### Enable Browser

```json
{
  "browser": {
    "enabled": true
  }
}
```

### Show Browser Window

```json
{
  "browser": {
    "headless": false
  }
}
```

### Use Brave Instead of Chrome

```json
{
  "browser": {
    "executablePath": "/usr/bin/brave-browser"
  }
}
```

### Use Different Default Profile

```json
{
  "browser": {
    "defaultProfile": "work"
  }
}
```

## Full Configuration Reference

```json5
{
  browser: {
    // Master enable/disable
    enabled: true, // default: true

    // Display settings
    headless: false, // Show window? (default: true)
    color: "#FF4500", // Tab accent color

    // Playwright requirements
    noSandbox: false, // Disable sandbox (Linux/Docker)
    executablePath: "/usr/bin/brave-browser", // Chrome/Brave/Edge path

    // Timeout settings
    remoteCdpTimeoutMs: 1500, // HTTP timeout for remote CDP
    remoteCdpHandshakeTimeoutMs: 3000, // WebSocket handshake timeout

    // Default profile
    defaultProfile: "openclaw", // "openclaw", "user", or custom

    // SSRF policy (network access control)
    ssrfPolicy: {
      dangerouslyAllowPrivateNetwork: true, // Allow localhost, 192.x, etc
      // hostnameAllowlist: ["*.example.com"],  // Whitelist specific hosts
      // allowedHostnames: ["localhost"],       // Exact hostname match
    },

    // Multi-profile configuration
    profiles: {
      // Managed profile (default)
      openclaw: {
        cdpPort: 18800, // Local Chrome DevTools Protocol port
        color: "#FF4500", // Tab accent (orange)
      },

      // Custom managed profile
      work: {
        cdpPort: 18801,
        color: "#0066CC", // Blue
      },

      // Existing session profile (your real Chrome)
      user: {
        driver: "existing-session", // Use Chrome MCP to attach
        attachOnly: true, // Don't launch, only attach
        color: "#00AA00", // Green
      },

      // Brave profile attachment
      brave: {
        driver: "existing-session",
        attachOnly: true,
        userDataDir: "~/Library/Application Support/BraveSoftware/Brave-Browser",
        color: "#FB542B",
      },

      // Remote CDP endpoint
      remote: {
        cdpUrl: "http://10.0.0.42:9222",
        color: "#FF00FF",
      },

      // Browserless.io
      browserless: {
        cdpUrl: "https://production-sfo.browserless.io?token=YOUR_API_KEY",
        color: "#00AA00",
      },

      // Browserbase (WebSocket)
      browserbase: {
        cdpUrl: "wss://connect.browserbase.com?apiKey=YOUR_API_KEY",
        color: "#F97316",
      },
    },

    // Default snapshot mode
    snapshotDefaults: {
      mode: "efficient", // "efficient" or "standard"
    },

    // Evaluate/JavaScript execution
    evaluateEnabled: true, // Allow JavaScript evaluation (disable if security concern)
  },
}
```

## Profile Types

### 1. OpenClaw-Managed Profiles

Dedicated browser instances with isolated user data.

```json
{
  "browser": {
    "profiles": {
      "openclaw": {
        "cdpPort": 18800,
        "color": "#FF4500"
      },
      "work": {
        "cdpPort": 18801,
        "color": "#0066CC"
      }
    }
  }
}
```

**Characteristics:**

- Always available
- Isolated from personal data
- Separate cookies/storage
- Best for automation

**Usage:**

```bash
openclaw browser --browser-profile openclaw navigate https://example.com
openclaw browser --browser-profile work navigate https://work.example.com
```

### 2. Existing-Session Profiles (Chrome MCP)

Attach to your already-running browser with logins intact.

```json
{
  "browser": {
    "profiles": {
      "user": {
        "driver": "existing-session",
        "attachOnly": true,
        "color": "#00AA00"
      },
      "brave": {
        "driver": "existing-session",
        "attachOnly": true,
        "userDataDir": "~/Library/Application Support/BraveSoftware/Brave-Browser",
        "color": "#FB542B"
      }
    }
  }
}
```

**Characteristics:**

- Requires browser running with remote debugging enabled
- Requires your approval on attach
- High-trust (can access all logins/data)
- Best when you're at the computer

**Setup:**

1. Enable remote debugging in browser (e.g., `chrome://inspect`)
2. Keep browser running
3. Use profile: `openclaw browser --browser-profile user snapshot`
4. Approve attach prompt in browser

**Usage:**

```bash
# Attach to Chrome
openclaw browser --browser-profile user navigate https://example.com

# Attach to Brave
openclaw browser --browser-profile brave navigate https://example.com
```

### 3. Remote CDP Profiles

Connect to a Chromium browser running elsewhere (VPS, Docker, etc).

```json
{
  "browser": {
    "profiles": {
      "remote": {
        "cdpUrl": "http://10.0.0.42:9222",
        "color": "#FF00FF"
      }
    }
  }
}
```

**With authentication:**

```json
{
  "browser": {
    "profiles": {
      "remote": {
        "cdpUrl": "https://user:password@provider.example.com:9222",
        "color": "#FF00FF"
      }
    }
  }
}
```

**Or with token:**

```json
{
  "browser": {
    "profiles": {
      "remote": {
        "cdpUrl": "https://provider.example.com:9222?token=SECRET_TOKEN",
        "color": "#FF00FF"
      }
    }
  }
}
```

### 4. Browserless.io

Hosted browser service with CDP endpoints.

```json
{
  "browser": {
    "enabled": true,
    "defaultProfile": "browserless",
    "remoteCdpTimeoutMs": 2000,
    "remoteCdpHandshakeTimeoutMs": 4000,
    "profiles": {
      "browserless": {
        "cdpUrl": "https://production-sfo.browserless.io?token=YOUR_KEY",
        "color": "#00AA00"
      }
    }
  }
}
```

**Get API key:**

1. Sign up at https://browserless.io
2. Copy API key from dashboard
3. Paste into `cdpUrl`

### 5. Browserbase

Hosted browser with residential proxies and CAPTCHA solving.

```json
{
  "browser": {
    "enabled": true,
    "defaultProfile": "browserbase",
    "remoteCdpTimeoutMs": 3000,
    "remoteCdpHandshakeTimeoutMs": 5000,
    "profiles": {
      "browserbase": {
        "cdpUrl": "wss://connect.browserbase.com?apiKey=YOUR_KEY",
        "color": "#F97316"
      }
    }
  }
}
```

**Get API key:**

1. Sign up at https://www.browserbase.com
2. Copy API Key from Overview
3. Paste into `cdpUrl`

## Browser Selection

### Auto-Detection

By default, OpenClaw picks the first available:

1. Chrome
2. Brave
3. Edge
4. Chromium
5. Chrome Canary

### Manual Selection

Specify browser executable:

```json
{
  "browser": {
    "executablePath": "/usr/bin/brave-browser"
  }
}
```

**Common paths:**

**macOS:**

```json
{
  "browser": {
    "executablePath": "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
  }
}
```

**Linux:**

```json
{
  "browser": {
    "executablePath": "/usr/bin/brave-browser"
  }
}
```

**Windows:**

```json
{
  browser: {
    executablePath": "C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe"
  }
}
```

## Security Configuration

### Strict SSRF Policy (Block Private Networks)

Only allow public URLs:

```json
{
  "browser": {
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": false,
      "hostnameAllowlist": ["*.example.com", "example.com"],
      "allowedHostnames": ["localhost"] // Exact match optional
    }
  }
}
```

### Allow Private Networks (Default - Trusted Lan)

```json
{
  "browser": {
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true
    }
  }
}
```

This allows localhost, 127.x, 192.x, 10.x, 172.16-31.x.

### Disable JavaScript Evaluation (Strict Security)

```json
{
  "browser": {
    "evaluateEnabled": false
  }
}
```

Prevents `browser evaluate` and `wait --fn` commands.

### Disable Sandbox (Docker/Linux)

For Docker or restricted environments:

```json
{
  "browser": {
    "noSandbox": true
  }
}
```

⚠️ Use only when necessary (Docker, constrained systems).

## Performance Configuration

### Efficient Snapshots (Lower Token Usage)

```json
{
  "browser": {
    "snapshotDefaults": {
      "mode": "efficient"
    }
  }
}
```

Reduces snapshot output by 50-70% via compact mode.

### Longer Timeouts (Slow Networks)

```json
{
  "browser": {
    "remoteCdpTimeoutMs": 5000,
    "remoteCdpHandshakeTimeoutMs": 10000
  }
}
```

### Headless Mode (Production/Servers)

```json
{
  "browser": {
    "headless": true
  }
}
```

Browser runs invisible (no window).

## Node Host Browser Proxy

If you run an OpenClaw node on the machine with your browser:

```json
{
  "gateway": {
    "nodes": {
      "browser": {
        "mode": "auto" // or "off" to disable proxy
      }
    }
  }
}
```

This routes browser commands to the node's local browser automatically.

## Docker Configuration

### Docker with Local Browser

```json
{
  "browser": {
    "enabled": true,
    "headless": false,
    "noSandbox": true,
    "executablePath": "/usr/bin/chromium"
  }
}
```

### Docker with Remote CDP

```json
{
  "browser": {
    "enabled": true,
    "profiles": {
      "remote": {
        "cdpUrl": "http://chromium-service:9222"
      }
    }
  }
}
```

## Environment Variables

Override config with env vars:

```bash
# Enable browser
export OPENCLAW_BROWSER_ENABLED=true

# Set executable
export OPENCLAW_BROWSER_EXECUTABLE_PATH=/usr/bin/brave-browser

# Set default profile
export OPENCLAW_BROWSER_DEFAULT_PROFILE=work

# Remote CDP URL
export OPENCLAW_BROWSER_REMOTE_CDP_URL=https://provider.example.com:9222

# Token for remote CDP
export BROWSERLESS_TOKEN=YOUR_API_KEY
# Then use in cdpUrl: ?token=${BROWSERLESS_TOKEN}
```

## Troubleshooting Configuration

### Browser Won't Start

```bash
# Check status
openclaw browser status

# Check logs
openclaw gateway logs | grep browser

# Verify executable
which brave-browser
# or
ls -la /Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser
```

### Can't Attach to Existing Session

```bash
# Check if browser is running with remote debugging
# Chrome: chrome://inspect
# Brave: brave://inspect
# Edge: edge://inspect

# Try attach
openclaw browser --browser-profile user status

# Approve prompt in browser
```

### Remote CDP Connection Fails

```bash
# Test connectivity
curl http://10.0.0.42:9222/json/version

# Check auth (if needed)
curl https://user:pass@provider.example.com:9222/json/version

# Verify cdpUrl format
# HTTP: http://host:port or https://host:port
# WebSocket: ws://host:port or wss://host:port?token=KEY
```

### Playwright Not Available

```bash
# Install Playwright
npm install playwright

# Or in Docker:
docker compose run --rm openclaw-cli \
  node /app/node_modules/playwright-core/cli.js install chromium
```

## Common Setups

### Development (Show Browser, Single Profile)

```json
{
  "browser": {
    "enabled": true,
    "headless": false,
    "defaultProfile": "openclaw"
  }
}
```

### Production (Hidden, Isolated)

```json
{
  "browser": {
    "enabled": true,
    "headless": true,
    "defaultProfile": "openclaw",
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": false,
      "hostnameAllowlist": ["example.com"]
    },
    "evaluateEnabled": false
  }
}
```

### Multi-Tenant (Multiple Profiles)

```json
{
  browser: {
    profiles: {
      openclaw: { cdpPort: 18800, color: "#FF4500" },
      client-a: { cdpPort: 18801, color: "#0066CC" },
      client-b: { cdpPort: 18802, color: "#00AA00" }
    }
  }
}
```

### With Your Chrome (Logged-In Sessions)

```json
{
  "browser": {
    "defaultProfile": "user",
    "profiles": {
      "openclaw": { "cdpPort": 18800 },
      "user": {
        "driver": "existing-session",
        "attachOnly": true
      }
    }
  }
}
```

### Docker with Remote Provider

```json
{
  "browser": {
    "enabled": true,
    "headless": true,
    "defaultProfile": "browserless",
    "profiles": {
      "browserless": {
        "cdpUrl": "https://production-sfo.browserless.io?token=${BROWSERLESS_TOKEN}",
        "color": "#00AA00"
      }
    }
  }
}
```

## Resetting Browser State

```bash
# Clear all cookies across profiles
openclaw browser cookies clear

# Clear specific profile cookies
openclaw browser --browser-profile work cookies clear

# Clear all storage
openclaw browser storage local clear
openclaw browser storage session clear

# Clear all browser data (delete profile)
# Managed profiles: data goes to Trash automatically
# Existing-session: use browser's built-in clear data
```
