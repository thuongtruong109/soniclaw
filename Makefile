chrome:
	cscript //nologo chrome.vbs

start:
	docker-compose down
	docker-compose up -d --build
	cscript //nologo chrome.vbs

stop:
	docker stop soniclaw

restart:
	docker restart soniclaw