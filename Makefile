SERVICE ?= soniclaw

cmd:
	docker compose exec $(SERVICE) sh -c "openclaw $(filter-out $@,$(MAKECMDGOALS))"

%:
	@:

chrome:
	cscript //nologo chrome.vbs

run:
	docker compose down
	docker compose up -d --build
	cscript //nologo chrome.vbs

shell:
	docker compose exec $(SERVICE) bash

logs:
	docker compose logs -f $(SERVICE)

# The live state lives in the openclaw-data volume. Use these to move
# ~/.openclaw/openclaw.json between the container and the repo copy.
config-pull:
	docker cp $(SERVICE):/root/.openclaw/openclaw.json .openclaw/openclaw.json

config-push:
	docker cp .openclaw/openclaw.json $(SERVICE):/root/.openclaw/openclaw.json
	docker compose restart $(SERVICE)

stop:
	docker stop $(SERVICE)

restart:
	docker restart $(SERVICE)

clean:
	docker compose exec $(SERVICE) sh -c "rm -rf /root/.openclaw/tmp/* /root/.openclaw/tasks /root/.openclaw/media /root/.openclaw/logs /root/.openclaw/subagents /root/.openclaw/workspace/memory"
	rm -rfv -- tmp