#!/usr/bin/make

include .env
export $(shell sed 's/=.*//' .env)

SHELL := /bin/bash
ENV_FILE ?= .env
DOCKER_COMPOSE=docker compose --env-file=${ENV_FILE}

# mount point for backup data
ES_BACKUP_VOLUME_PATH?=/hdd-zfs/monitoring-es-backups/

.DEFAULT_GOAL := dev

#----------------#
# Docker Compose #
#----------------#
dev: replace_env build create_external_networks up

build:
	@echo "🥫 Building containers …"
	${DOCKER_COMPOSE} build

up:
	@echo "🥫 Starting containers …"
	${DOCKER_COMPOSE} up -d 2>&1

create_backups_dir:
	@echo "🥫 Ensure backups dir for elasticsearch"
	docker compose run --rm -u root elasticsearch bash -c "mkdir -p /opt/elasticsearch/backups && chown elasticsearch:root /opt/elasticsearch/backups"
# the chown -R takes far too long on a big backup directory through NFS with high latency…
# removed it for now
#	docker compose run --rm -u root elasticsearch bash -c "mkdir -p /opt/elasticsearch/backups && chown elasticsearch:root -R /opt/elasticsearch/backups"

down:
	@echo "🥫 Bringing down containers …"
	${DOCKER_COMPOSE} down --remove-orphans

hdown:
	@echo "🥫 Bringing down containers and associated volumes …"
	${DOCKER_COMPOSE} down -v --remove-orphans

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
	@echo "🥫 Reading logs (docker compose) …"
	${DOCKER_COMPOSE} logs -f

#------------#
# Production #
#------------#

# Create external networks (useful in dev)
create_external_networks:
	docker network create reverse_proxy_network || true
# Create all external volumes needed for production. Using external volumes is useful to prevent data loss (as they are not deleted when performing docker down -v)
create_external_volumes:
	docker volume create ${COMPOSE_PROJECT_NAME}_influxdb-data
	docker volume create ${COMPOSE_PROJECT_NAME}_grafana-data
	docker volume create ${COMPOSE_PROJECT_NAME}_elasticsearch-data
	docker volume create ${COMPOSE_PROJECT_NAME}_prometheus-data
	docker volume create ${COMPOSE_PROJECT_NAME}_alertmanager-data
	docker volume create --opt type=none --opt o=bind --opt device=${ES_BACKUP_VOLUME_PATH} ${COMPOSE_PROJECT_NAME}_elasticsearch-backup

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
