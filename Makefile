SHELL := /bin/bash
.DEFAULT_GOAL = help

COMPOSE = docker compose --env-file=.env.local
FILE = -f docker-compose.yml
EXEC = ${COMPOSE} exec
RUN = ${COMPOSE} run
CONSOLE = symfony console

DALILA-CLIENT = dalila-client
DALILA-API_PHP = dalila-api_php
DALILA-API_NGINX = dalila-api_nginx
DALILA-POSTGRES = dalila-postgres
DALILA-PGADMIN = dalila-pgadmin
DALILA-MODELS_API = dalila-models_api
DALILA-LLM_API = dalila-llm_api

EXEC-API_PHP = ${EXEC} ${DALILA-API_PHP}-service

##
## General
##

.PHONY: help
# Show this help message.
help:
	@cat $(MAKEFILE_LIST) | docker run --rm -i xanders/make-help

.PHONY: start
# Start project.
start: perm clear sr up cpr-i jwt db cc perm

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

.PHONY: clear
# Clear projet.
clear:
	rm -rf ./pgadmin/azurecredentialcache ./pgadmin/sessions/ ./pgadmin/storage
	rm -f ./pgadmin/pgadmin4*

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

.PHONY: submod
# Fetch code from submodules.
submod:
	git submodule update --remote --merge

.PHONY: init-submod
# Initializes the submodule branch.
init-submod:
	git submodule update --init --recursive

.PHONY: reset-submod
# To reset all sub-modules
reset-submod:
	git submodule foreach git reset --hard origin/main

##
## Symfony
##

EXEC_SC = ${EXEC-API_PHP} ${CONSOLE}

.PHONY: cc
# Clear the cache.
cc:
	${EXEC} ${DALILA-API_PHP}-service symfony console c:c --no-warmup
	${EXEC} ${DALILA-API_PHP}-service symfony console c:warmup

.PHONY: jwt
# Generate the JWT keys.
jwt:
	${EXEC} ${DALILA-API_PHP}-service symfony console lexik:jwt:generate-keypair --skip-if-exists

##
## Symfony - Database
##

DOCTRINE = ${EXEC_SC} doctrine:
DOCTRINE_DB = ${DOCTRINE}d:
DOCTRINE_SCHEMA = ${DOCTRINE}s:
DOCTRINE_FIXTURES = ${DOCTRINE}f:
DOCTRINE_CACHE = ${DOCTRINE}cache:
DOCTRINE_CACHE_CLEAR = ${DOCTRINE_CACHE}clear-

.PHONY: build
# Drop, create db, update schema and load fixtures
db: db-cache db-d db-c db-su db-fl

.PHONY: db-d
# Drop database
db-d:
	${DOCTRINE_DB}d --if-exists -f

.PHONY: db-c
# Create database
db-c:
	${DOCTRINE_DB}c --if-not-exists

.PHONY: db-su
# Update database schema
db-su:
	${DOCTRINE_SCHEMA}u -f

.PHONY: db-v
# Check database schema
db-v:
	${DOCTRINE_SCHEMA}v

.PHONY: db-fl
# Load fixtures
db-fl:
	${DOCTRINE_FIXTURES}l -n

.PHONY: db-m
# Make migrations
db-m:
	${DOCTRINE}m:m

.PHONY: db-cache
# Clear doctrine cache
db-cache: db-cache-r db-cache-q db-cache-m

.PHONY: db-cache-r
# Clear result
db-cache-r:
	${DOCTRINE_CACHE_CLEAR}result

.PHONY: db-cache-q
# Clear query
db-cache-q:
	${DOCTRINE_CACHE_CLEAR}query

.PHONY: db-cache-m
# Clear metadata
db-cache-m:
	${DOCTRINE_CACHE_CLEAR}metadata

##
## Composer
##

COMPOSER = ${EXEC-API_PHP} composer

.PHONY: cpr
# Composer in php-container with your command, c='{value}''
cpr:
	${COMPOSER} $(c)

.PHONY: cpr-i
# Install php dependencies
cpr-i:
	${COMPOSER} install

.PHONY: cpr-u
# Update php dependencies
cpr-u:
	${COMPOSER} update

.PHONY: cpr-perm
# Add the folder to the safe.directory list at the system level
cpr-perm:
	${EXEC-API_PHP} git config --global --add safe.directory '*'

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

.PHONY: logs-gres
# Prompt logs of gres container.
logs-gres:
	docker logs --follow ${DALILA-POSTGRES}-container

.PHONY: logs-pgadmin
# Prompt logs of pgadmin container.
logs-pgadmin:
	docker logs --follow ${DALILA-PGADMIN}-container

.PHONY: logs-models_api
# Prompt logs of models_api container.
logs-models_api:
	docker logs --follow ${DALILA-MODELS_API}-container

.PHONY: logs-llm_api
# Prompt logs of llm_api container.
logs-llm_api:
	docker logs --follow ${DALILA-LLM_API}-container

##
## Containers
##

.PHONY: client
# Enter in client container.
client:
	${EXEC} ${DALILA-CLIENT}-service ${SHELL}

.PHONY: api
# Enter in api_php container.
api:
	${EXEC} ${DALILA-API_PHP}-service ${SHELL}

.PHONY: gre
# Enter in postgre container.
gre:
	${EXEC} ${DALILA-POSTGRES}-service ${SHELL}

.PHONY: pgadmin
# Enter in pgadmin container.
pgadmin:
	${EXEC} ${DALILA-PGADMIN}-service ${SHELL}

.PHONY: models_api
# Enter in models_api container.
models_api:
	${EXEC} ${DALILA-MODELS_API}-service ${SHELL}

.PHONY: llm_api
# Enter in llm_api container.
llm_api:
	${EXEC} ${DALILA-LLM_API}-service ${SHELL}
