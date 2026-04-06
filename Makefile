SERVICE ?= soniclaw

cmd:
	docker compose exec $(SERVICE) sh -c "openclaw $(filter-out $@,$(MAKECMDGOALS))"

%:
	@:

chrome:
	cscript //nologo chrome.vbs

run:
	docker-compose down
	docker-compose up -d --build
	cscript //nologo chrome.vbs

stop:
	docker stop $(SERVICE)

restart:
	docker restart $(SERVICE)

clean:
	rm -rfv -- tmp .openclaw/tasks .openclaw/media .openclaw/logs .openclaw/subagents .openclaw/workspace/memory