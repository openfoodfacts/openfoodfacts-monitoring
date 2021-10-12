#!/usr/bin/make

include .env
export $(shell sed 's/=.*//' .env)

SHELL := /bin/bash
ENV_FILE ?= .env
DOCKER_COMPOSE=docker-compose --env-file=${ENV_FILE}

.DEFAULT_GOAL := dev

#----------------#
# Docker Compose #
#----------------#
dev: replace_env up

up:
	@echo "🥫 Building and starting containers …"
	${DOCKER_COMPOSE} up -d --build 2>&1

down:
	@echo "🥫 Bringing down containers …"
	${DOCKER_COMPOSE} down

hdown:
	@echo "🥫 Bringing down containers and associated volumes …"
	${DOCKER_COMPOSE} down -v

reset: hdown up

restart:
	@echo "🥫 Restarting containers …"
	${DOCKER_COMPOSE} restart

status:
	@echo "🥫 Getting container status …"
	${DOCKER_COMPOSE} ps

livecheck:
	@echo "🥫 Running livecheck …"
	docker/docker-livecheck.sh

log:
	@echo "🥫 Reading logs (docker-compose) …"
	${DOCKER_COMPOSE} logs -f

#------------#
# Production #
#------------#
create_external_volumes:
	docker volume create influxdb-data
	docker volume create grafana-data
	docker volume create elasticsearch-data
	docker volume create prometheus-data
	docker volume create alertmanager-data

replace_env:
	. .env && envsubst '$${SLACK_WEBHOOK_URL_INFRASTRUCTURE_ALERTS_0}' < configs/alertmanager/config.tpl.yml > configs/alertmanager/config.yml

#---------#
# Cleanup #
#---------#
prune:
	@echo "🥫 Pruning unused Docker artifacts (save space) …"
	docker system prune -af

prune_cache:
	@echo "🥫 Pruning Docker builder cache …"
	docker builder prune -f

clean: hdown prune prune_cache
