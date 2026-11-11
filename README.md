<div align="center">

# Soniclaw

Lightweight OpenClaw automation environment with remote Chrome CDP integration, Docker runtime, and persistent browser workflows.

<p>
  <img src="https://img.shields.io/badge/OpenClaw-Automation-black?style=flat-square" />
  <img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Chrome-CDP-orange?style=flat-square&logo=googlechrome&logoColor=white" />
  <img src="https://img.shields.io/badge/Ubuntu-22.04-E95420?style=flat-square&logo=ubuntu&logoColor=white" />
  <img src="https://img.shields.io/badge/WSL2-Compatible-4D4D4D?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" />
</p>

</div>

## Overview

SonicLaw provides a production-ready automation runtime for OpenClaw with:

- Remote Chrome DevTools Protocol (CDP) support
- Dockerized execution environment
- Persistent browser sessions
- SSH-enabled automation container
- Multi-agent OpenClaw workspace setup
- WSL2 ↔ Windows browser bridge

Designed for stable browser automation workflows without requiring local browser execution inside containers.

## Features

- Remote Chrome attachment via CDP
- Auto-detect Windows host from WSL2/Docker
- OpenClaw gateway preconfigured
- Browser worker architecture
- Persistent `.openclaw` workspace
- Docker Compose ready
- SSH access for debugging/runtime control
- Minimal runtime dependencies

## Architecture

```text
Windows Chrome
   │
   │ Remote Debugging Port (9222)
   ▼
WSL2 / Docker Network
   │
   ▼
SonicLaw Container
   ├── OpenClaw Gateway
   ├── Browser Worker
   └── Automation Runtime
```

## Quick Start

### 1. Start Chrome with remote debugging

```bash
chrome.exe ^
  --remote-debugging-port=9222 ^
  --remote-debugging-address=0.0.0.0 ^
  --user-data-dir="C:\chrome-debug"
```

Or use:

```bash
make chrome
```

### 2. Start SonicLaw

```bash
make run
```

Or:

```bash
docker compose up -d --build
```

### 3. Verify environment

```bash
openclaw browser status
```

### 4. Open the Control UI

```text
http://localhost:18789/
```

Use the gateway token when prompted. It is the `GATEWAY_TOKEN` value from
`./.openclaw/.env`, or print it from inside the container:

```bash
make cmd gateway auth-token --show
```

## Default Ports

| Port    | Purpose          |
| ------- | ---------------- |
| `22`    | SSH access       |
| `18789` | OpenClaw Gateway |
| `9222`  | Chrome CDP       |

## Project Structure

```text
.
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── chrome.vbs
├── Makefile
└── .openclaw/
```

## Configuration

Live state (config, credentials, sessions, SQLite databases) lives in the
`openclaw-data` Docker volume, mounted at `/root/.openclaw`:

```text
openclaw-data -> /root/.openclaw
```

The repo's `./.openclaw` directory is mounted read-only at `/seed` and is only
imported into the volume **the first time** the container starts. After that,
edit the live config through the container:

```bash
make shell
nano /root/.openclaw/openclaw.json   # or: make cmd config get gateway
```

To move `openclaw.json` between the container and the repo copy:

```bash
make config-pull   # container -> ./.openclaw/openclaw.json
make config-push   # ./.openclaw/openclaw.json -> container (+ restart)
```

> Why not bind-mount `./.openclaw` directly? Docker Desktop's Windows bind
> mounts break `rename()` + `fstat()` on an open handle, which OpenClaw uses for
> atomic writes. `openclaw doctor --fix` then fails with
> `ENOENT: no such file or directory, fstat` and the Gateway never starts.
> If you prefer a bind mount, run the project from the WSL2 filesystem
> (e.g. `/home/<you>/soniclaw`) instead of `C:` / `D:`.

Remote browser profile is written by the entrypoint on every start (the
Windows host IP is auto-detected):

```json
{
  "browser": {
    "defaultProfile": "remote",
    "profiles": {
      "remote": {
        "cdpUrl": "http://host.docker.internal:9222"
      }
    }
  }
}
```

## Available Commands

| Command        | Description                    |
| -------------- | ------------------------------ |
| `make run`     | Build and start container      |
| `make stop`    | Stop runtime                   |
| `make restart` | Restart container              |
| `make chrome`  | Launch Chrome with CDP         |
| `make clean`   | Cleanup temporary runtime data |

## Runtime Notes

- Chrome runs externally on Windows
- Container only attaches through CDP
- Optimized for WSL2 networking
- Browser sessions remain persistent between container restarts

## Security

This repository is intended for trusted local environments.

Before production usage:

- Change default SSH credentials
- Restrict exposed ports
- Use secure gateway tokens
- Avoid exposing CDP publicly

## Requirements

- Docker
- Docker Compose
- Google Chrome
- WSL2 (recommended)
- OpenClaw CLI

## Compatibility

| Platform       | Status       |
| -------------- | ------------ |
| Windows + WSL2 | Recommended  |
| Native Linux   | Supported    |
| macOS          | Experimental |

## Tutorial:

1. Build image

```bash
docker build -t openclaw .
```

2. Run Image

- Click image > Config Port: 18789, Host: 22
- Open CLI

```bash
curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash
```

3. Setup Gateway:

- Open container CLI

```bash
openclaw gateway
```

```bash
nano /root/.openclaw/openclaw.json
```

- Edit
  "gateway": {
  "bind": "lan"
  },

4. Pair devices

```bash
openclaw devices list
```

```bash
openclaw devices approve [DEVICE_ID]
```

### Others commands

- Pair with Telegram:

```bash
openclaw pairing approve telegram [TELEGRAM_PAIRING_CODE]
```

- Allow Chrome remote debugging

```bash
chrome://inspect/#remote-debugging
```

```bash
chrome.exe --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --remote-allow-origins=* --user-data-dir="C:\chrome-debug"
```

- Update config

```bash
openclaw onboard
```

- Configure web settings

```bash
openclaw configure --section web
```

- Get token

```bash
openclaw config get gateway.auth.token
```

- Install skill

```bash
npx clawhub install <skill-name>
```

- Restart update

```bash
openclaw doctor --fix
```

## Troubleshooting

### `http://localhost:18789/` shows nothing / container keeps restarting

Check the logs:

```bash
docker compose logs --tail 50 soniclaw
```

If you see `openclaw doctor --fix failed` together with
`ENOENT: no such file or directory, fstat`, the state directory is on a
Windows bind mount (`C:` / `D:`). OpenClaw's atomic file replace fails there,
so the Gateway never binds. Use the `openclaw-data` volume configured in
`docker-compose.yml`, or move the project into the WSL2 filesystem.

If the Gateway is up but the UI does not load, the container is healthy only
when `curl -fsS http://127.0.0.1:18789/healthz` succeeds inside the container:

```bash
docker compose exec soniclaw curl -fsS http://127.0.0.1:18789/healthz
```

### Cannot connect to Chrome CDP

Verify Chrome is running:

```bash
curl http://localhost:9222/json/version
```

Check Docker ↔ Windows networking:

```bash
curl http://host.docker.internal:9222/json/version
```

## Related

- OpenClaw Runtime
- Chrome DevTools Protocol
- Docker Engine

## License

MIT License

## References

- Skill: https://clawhub.ai/skills
- Document: https://docs.openclaw.ai
- https://openclawai.vn/huong-dan/lich-trinh
- https://openclaws.io/vi/install/
- https://open-claw.bot/docs
- https://openclawvietnam.xyz
- https://docs.claw.so/engine/tools/browser/
- https://openclawcn.com/en/docs/web/
- https://www.learnclawdbot.org/docs/tools/browser-login
- https://www.getopenclaw.ai/en/docs/configuration#model-params

<!--
https://www.youtube.com/watch?v=5vDeIvCqpfs&t=1195s
https://viblo.asia/p/cam-nang-bop-nho-kich-thuoc-config-tren-openclaw-chong-tran-rac-tranh-thung-vi-pPLkN1N6JRZ
https://openclaws.io/vi/blog/openclaw-docker-deployment/
https://github.com/Tsangares/tiktok-post
https://azdigi.com/blog/tri-tue-nhan-tao/huong-dan-openclaw
https://getclawkit.com/docs/troubleshooting/device-token-mismatch
https://www.youtube.com/watch?v=HcSiLRP7qyI
https://azdigi.com/blog/tri-tue-nhan-tao/toi-uu-chi-phi-token-openclaw
https://www.youtube.com/watch?v=GKMeJtqlo2Q -->

<!-- netsh interface portproxy add v4tov4 listenport=9222 listenaddress=0.0.0.0 connectport=56039 connectaddress=127.0.0.1 -->
