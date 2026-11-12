<div align="center">

# Soniclaw

OpenClaw automation runtime with remote Chrome CDP, Docker, and persistent state.

<p>
  <img src="https://img.shields.io/badge/OpenClaw-2026.11.2-black?style=flat-square" />
  <img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Chrome-CDP-orange?style=flat-square&logo=googlechrome&logoColor=white" />
  <img src="https://img.shields.io/badge/Ubuntu-24.04-E95420?style=flat-square&logo=ubuntu&logoColor=white" />
  <img src="https://img.shields.io/badge/WSL2-Compatible-4D4D4D?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" />
</p>

</div>

## Overview

Soniclaw ships a pinned OpenClaw version in a small Docker image and attaches it
to the Chrome instance running on your host through the Chrome DevTools Protocol
(CDP). The browser never runs inside the container, so you keep your normal
Chrome profile, extensions, and logins while the agent drives it remotely.

## Features

- Remote Chrome attachment via CDP (`host.docker.internal:9222`)
- Windows host IP auto-detected at container start
- OpenClaw Gateway with token auth and the Control UI on port `18789`
- Persistent state in a Docker volume (config, credentials, sessions, SQLite)
- Repo copy of `.openclaw` used as a first-run seed template
- Multi-agent workspace (`main`, `browser-worker`, `light`, `pro`)
- Optional Telegram channel, Google web search
- Docker Compose only: no OpenClaw CLI needed on the host
- Windows helper to launch Chrome with remote debugging

## Architecture

```text
Windows Chrome  ──(CDP :9222)──┐
                               │
Docker Desktop / WSL2 ─────────┤
                               ▼
                      Soniclaw container
                      ├── OpenClaw Gateway (:18789)
                      ├── Control UI / WebSocket
                      └── browser plugin → CDP client
                               │
                     openclaw-data volume
                     (/root/.openclaw)
```

## Quick Start

### 1. Start Chrome with remote debugging (Windows)

```powershell
make chrome
```

or manually:

```powershell
chrome.exe --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --remote-allow-origins=* --user-data-dir="$env:LOCALAPPDATA\chrome-debug"
```

On Linux/macOS run Chrome with the same flags yourself.

### 2. Start Soniclaw

```bash
make run
```

Equivalent to `docker compose down && docker compose up -d --build`.

### 3. Verify

```bash
make cmd browser status
docker compose ps
```

### 4. Open the Control UI

```text
http://localhost:18789/
```

The first start generates a `GATEWAY_TOKEN` in `/root/.openclaw/.env` (inside
the volume). Paste it into the UI's **Gateway secret** field. To print it from
inside the container (needs an interactive terminal):

```bash
make cmd gateway auth-token --show
```

## Ports

| Port    | Where            | Purpose                        |
| ------- | ---------------- | ------------------------------ |
| `18789` | container (published) | OpenClaw Gateway + Control UI |
| `9222`  | host only        | Chrome remote debugging (CDP)  |

The CDP port is deliberately not published: the container reaches it through
`host.docker.internal`.

## Project Structure

```text
.
├── Dockerfile           # pinned OpenClaw image
├── docker-compose.yml   # service, port, healthcheck, volume
├── entrypoint.sh        # seed volume, token bootstrap, doctor, gateway
├── chrome.vbs           # launch Windows Chrome with CDP
├── Makefile             # run/stop/logs/doctor/config helpers
├── LICENSE
└── .openclaw/           # seed template (imported on first start only)
    ├── .env.example
    ├── openclaw.json
    └── workspace/
```

## Configuration

Live state (config, credentials, sessions, SQLite databases) lives in the
`openclaw-data` Docker volume, mounted at `/root/.openclaw`:

```text
openclaw-data -> /root/.openclaw
```

The repo's `./.openclaw` directory is mounted read-only at `/seed` and imported
into the volume **only on the first start**. After that, edit the live config
through the container:

```bash
make shell
nano /root/.openclaw/openclaw.json   # or: make cmd config get gateway
```

To move `openclaw.json` between the container and the repo copy:

```bash
make config-pull   # container -> ./.openclaw/openclaw.json
make config-push   # ./.openclaw/openclaw.json -> container (+ restart)
```

> `config-push` overwrites the live config, including the auth profile
> references that point at stored credentials. Pull first if in doubt.

Exported files (screenshots, reports, media) live in
`/root/.openclaw/workspace/exports`; copy them to the repo with:

```bash
make pull-exports
```

> **Why not bind-mount `./.openclaw` directly?**
> Docker Desktop's Windows bind mounts break `rename()` + `fstat()` on an open
> handle, which OpenClaw uses for atomic writes. `openclaw doctor --fix` then
> fails with `ENOENT: no such file or directory, fstat` and the Gateway never
> starts. If you prefer a bind mount, run the project from the WSL2 filesystem
> (e.g. `/home/<you>/soniclaw`) instead of `C:` / `D:`.

The remote browser profile is rewritten by the entrypoint on every start with
the detected Windows host IP:

```json
{
  "browser": {
    "defaultProfile": "remote",
    "profiles": {
      "remote": { "cdpUrl": "http://host.docker.internal:9222" }
    }
  }
}
```

## Model providers

The seed config uses `openai/gpt-6.1-sol` (Codex runtime) with Anthropic
fallbacks. A fresh volume has no credentials yet, so `openclaw doctor` reports a
missing `openai:default` profile until you sign in once:

```bash
make cmd models auth login --provider openai --method device-code
```

Or put provider keys in the volume's `.env` and restart:

```bash
make shell
nano /root/.openclaw/.env    # ANTHROPIC_API_KEY=..., OPENAI_API_KEY=...
make restart
```

## Commands

| Command             | Description                                        |
| ------------------- | -------------------------------------------------- |
| `make run`          | Rebuild and start the container                    |
| `make stop`         | Stop the container                                 |
| `make restart`      | Restart the container                              |
| `make logs`         | Follow container logs                              |
| `make shell`        | Open a shell in the container                      |
| `make doctor`       | Run `openclaw doctor --fix`                        |
| `make cmd <args>`   | Run an OpenClaw CLI command (`make cmd gateway status`) |
| `make chrome`       | Launch Windows Chrome with CDP                     |
| `make config-pull`  | Copy live `openclaw.json` into the repo            |
| `make config-push`  | Push repo `openclaw.json` into the container       |
| `make pull-exports` | Copy agent exports out to `./exports`              |
| `make clean`        | Delete temporary runtime data (keeps the volume)   |
| `make reset`        | **DANGER** delete the volume (all state)           |

## Runtime Notes

- Chrome runs on the host, the container only attaches through CDP.
- The Gateway boots in ~30-60s (doctor + migrations), hence the 90s
  healthcheck `start_period`.
- Sessions, credentials, and device pairings survive container restarts.
- The image is ~2.7 GB, mostly the pinned OpenClaw `node_modules`.
- `make run` rebuilds the image, so changes to `Dockerfile` or `entrypoint.sh`
  are picked up.

## Security

This repository is meant for trusted local environments.

- Change `GATEWAY_TOKEN` and keep it private; the UI is reachable on your LAN
  because `gateway.bind` is `lan` (needed inside Docker).
- Do not publish port `9222`; CDP gives full control over your browser.
- Keep `.openclaw/.env` out of git (already ignored).
- Rotate `TELEGRAM_BOT_TOKEN`, `GOOGLE_WEB_SEARCH_API_KEY`, and provider keys
  before sharing a fork.
- Prefer a tunnel (SSH/Tailscale) over exposing `18789` to the internet.

## Requirements

- Docker Engine / Docker Desktop with Compose v2
- Google Chrome (for CDP automation)
- WSL2 backend on Windows (recommended)
- `make` and `cscript` only if you use the Makefile helpers on Windows

## Compatibility

| Platform       | Status                    |
| -------------- | ------------------------- |
| Windows + WSL2 | Recommended               |
| Native Linux   | Supported (no `make chrome`) |
| macOS          | Experimental              |

## Troubleshooting

### `http://localhost:18789/` shows nothing / container keeps restarting

```bash
docker compose logs --tail 50 soniclaw
```

If you see `openclaw doctor --fix failed` together with
`ENOENT: no such file or directory, fstat`, the state directory is on a Windows
bind mount (`C:` / `D:`). Use the `openclaw-data` volume from
`docker-compose.yml`, or move the project into the WSL2 filesystem.

If the Gateway is up but the UI does not load, check it from inside:

```bash
docker compose exec soniclaw curl -fsS http://127.0.0.1:18789/healthz
```

### UI loads but asks for a token

`GATEWAY_TOKEN` lives in the `.env` file inside the volume. Print it with
`make cmd gateway auth-token --show`, or reset it:

```bash
make shell
nano /root/.openclaw/.env    # set GATEWAY_TOKEN=<new value>
```

then `make restart`.

### Cannot connect to Chrome CDP

```bash
curl http://localhost:9222/json/version                  # from Windows
docker compose exec soniclaw curl http://host.docker.internal:9222/json/version
```

The second command must return JSON. If it does not, Chrome is not listening on
`0.0.0.0` (relaunch it with `make chrome`).

### `bad interpreter` or `#!/bin/sh^M`

The `entrypoint.sh` was checked out with CRLF. The repo ships a
`.gitattributes` that forces LF; re-checkout with:

```bash
git rm --cached -r . && git reset --hard
```

## References

- OpenClaw docs: https://docs.openclaw.ai
- OpenClaw gateway remote access: https://docs.openclaw.ai/gateway/remote
- Browser tool: https://docs.claw.so/engine/tools/browser/
- Skills hub: https://clawhub.ai/skills
- Chrome DevTools Protocol: https://chromedevtools.github.io/devtools-protocol/

## License

MIT — see [LICENSE](LICENSE).
