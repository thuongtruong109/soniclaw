SERVICE ?= soniclaw

.PHONY: cmd chrome run stop restart shell logs doctor oauth-forward-logs siwc-callback config-pull config-push pull-exports clean reset

# Run an OpenClaw CLI command inside the container, e.g.:
#   make cmd gateway status
#   make cmd browser status
cmd:
	docker compose exec $(SERVICE) sh -c "openclaw $(filter-out $@,$(MAKECMDGOALS))"

# Swallow the extra words passed to `make cmd ...` so make does not fail.
%:
	@:

chrome:
	cscript //nologo chrome.vbs

run:
	docker compose down
	docker compose up -d --build

stop:
	docker compose stop

restart:
	docker compose restart

shell:
	docker compose exec $(SERVICE) bash

logs:
	docker compose logs -f $(SERVICE)

# The sidecar that makes the OAuth loopback callbacks reachable from Windows.
oauth-forward-logs:
	docker compose logs -f oauth-forward

# Fallback for "Sign in with ChatGPT (Beta)" without restarting the stack.
# After the browser shows ERR_CONNECTION_REFUSED, copy the full URL from the
# address bar and replay it from inside the container:
#   make siwc-callback URL="http://localhost:8080/auth/callback?code=...&state=..."
CALLBACK_URL := $(subst //localhost:,//127.0.0.1:,$(URL))
siwc-callback:
	@test -n "$(URL)" || { \
		echo 'usage: make siwc-callback URL="http://localhost:8080/auth/callback?code=...&state=..."'; \
		exit 1; \
	}
	docker compose exec -T $(SERVICE) sh -c "curl -fsS '$(CALLBACK_URL)'"

doctor:
	docker compose exec $(SERVICE) openclaw doctor --fix

# The live state lives in the openclaw-data volume. Use these to move
# ~/.openclaw/openclaw.json between the container and the repo copy.
config-pull:
	docker compose cp $(SERVICE):/root/.openclaw/openclaw.json .openclaw/openclaw.json

# WARNING: overwrites the live config (credentials/profile references included).
config-push:
	docker compose cp .openclaw/openclaw.json $(SERVICE):/root/.openclaw/openclaw.json
	docker compose restart $(SERVICE)

# Copy files the agent exported to ./exports so Windows can open them.
pull-exports:
	docker compose cp $(SERVICE):/root/.openclaw/workspace/exports/. ./exports/

clean:
	@if docker compose ps --status running --quiet $(SERVICE) | grep -q .; then \
		docker compose exec $(SERVICE) sh -c "rm -rf /root/.openclaw/tmp/* /root/.openclaw/logs /root/.openclaw/tasks /root/.openclaw/subagents"; \
	else \
		echo "container is not running"; \
	fi
	rm -rf -- tmp

# DANGER: deletes the openclaw-data volume (config, credentials, sessions).
reset:
	docker compose down -v
