SHELL := /bin/bash
.DEFAULT_GOAL = help

COMPOSE = docker compose --env-file=.env.local
FILE = -f docker-compose.yml
EXEC = ${COMPOSE} exec
RUN = ${COMPOSE} run

DALILA-CLIENT = dalila-client
DALILA-API_PHP = dalila-api_php
DALILA-API_NGINX = dalila-api_nginx
DALILA-POSTGRE = dalila-postgres
DALILA-PGADMIN = dalila-pgadmin

.PHONY: help
# Show this help message.
help:
	@cat $(MAKEFILE_LIST) | docker run --rm -i xanders/make-help

.PHONY: start
# Start project.
start: perm sr up cc perm

.PHONY: up
# Kill all containers, rebuild and up them.
up: kill
	${COMPOSE} ${FILE} up -d --build

.PHONY: kill
# Kill all containers.
kill:
	${COMPOSE} kill $$(docker ps -q) || true

.PHONY: stop
# Stop all containers.
stop:
	${COMPOSE} stop

.PHONY: rm
# Remove all containers.
rm:
	${COMPOSE} rm -f

.PHONY: sr
# Stop and remove all containers.
sr: stop rm

.PHONY: purge
# Stop and remove all containers and prune volumes, networks, containers and images.
purge:
	make sr
	docker volume prune -f
	docker network prune -f
	docker container prune -f
	docker image prune -f

.PHONY: ps
# List all containers.
ps:
	${COMPOSE} ps -a

.PHONY: perm
# Fix permissions of all files.
perm:
	sudo chown -R www-data:$(USER) .
	sudo chmod -R g+rwx .

.PHONY: restart
# Restart all containers correctly.
restart:
	clear
	make perm sr up logs

.PHONY: client
# Enter in client container.
client:
	${EXEC} ${DALILA-CLIENT} ${SHELL}

.PHONY: api
# Enter in api_php container.
api:
	${EXEC} ${DALILA-API_PHP}-service ${SHELL}

##
## Symfony
##

.PHONY: cc
# Clear the cache.
cc:
	${EXEC} ${DALILA-API_PHP}-service symfony console c:c --no-warmup
	${EXEC} ${DALILA-API_PHP}-service symfony console c:warmup

##
## Logs
##

.PHONY: logs-client
# Prompt logs of client container.
logs-client:
	docker logs --follow ${DALILA-CLIENT}-container

.PHONY: logs-api_php
# Prompt logs of api_php container.
logs-api_php:
	docker logs --follow ${DALILA-API_PHP}-container

.PHONY: logs-api_nginx
# Prompt logs of api_nginx container.
logs-api_nginx:
	docker logs --follow ${DALILA-API_NGINX}-container

.PHONY: logs-postgres
# Prompt logs of postgres container.
logs-postgres:
	docker logs --follow ${DALILA-POSTGRE}-container

.PHONY: logs-pgadmin
# Prompt logs of pgadmin container.
logs-pgadmin:
	docker logs --follow ${DALILA-PGADMIN}-container
