SHELL := /bin/bash
.DEFAULT_GOAL = help

COMPOSE = docker compose
FILE = -f docker-compose.yml
EXEC = ${COMPOSE} exec
RUN = ${COMPOSE} run

DALILA-API_PHP = dalila-api_php-service

.PHONY: help
# Show this help message.
help:
	@cat $(MAKEFILE_LIST) | docker run --rm -i xanders/make-help

.PHONY: start
# Start project.
start: perm up cc perm

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

.PHONY: logs-client
# Prompt logs of container.
logs:
	docker logs --follow dalila-client-container

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
	${EXEC} dalila-client-service ${SHELL}

.PHONY: api
# Enter in api_php container.
api:
	${EXEC} ${DALILA-API_PHP} ${SHELL}

##
## Symfony
##

.PHONY: cc
# Clear the cache.
cc:
	${EXEC} ${DALILA-API_PHP} symfony c:c --no-warmup
	${EXEC} ${DALILA-API_PHP} symfony c:warmup
