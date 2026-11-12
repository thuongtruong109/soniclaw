SERVICE ?= soniclaw

.PHONY: cmd chrome run stop restart shell logs doctor config-pull config-push pull-exports clean reset

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
