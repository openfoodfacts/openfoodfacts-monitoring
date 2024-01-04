#!/usr/bin/make

include .env
export $(shell sed 's/=.*//' .env)

SHELL := /bin/bash
ENV_FILE ?= .env
DOCKER_COMPOSE=docker-compose --env-file=${ENV_FILE}

# mount point for shared data
NFS_VOLUMES_ADDRESS ?= 10.0.0.3
NFS_VOLUMES_BASE_PATH ?= /rpool/backups/monitoring-volumes/

.DEFAULT_GOAL := dev

#----------------#
# Docker Compose #
#----------------#
dev: replace_env build up

build:
	@echo "🥫 Building containers …"
	${DOCKER_COMPOSE} build

up:
	@echo "🥫 Starting containers …"
	${DOCKER_COMPOSE} up -d 2>&1

create_backups_dir:
	@echo "🥫 Ensure backups dir for elasticsearch"
	docker-compose run --rm -u root elasticsearch bash -c "mkdir -p /opt/elasticsearch/backups && chown elasticsearch:root /opt/elasticsearch/backups"
# the chown -R takes far too long on a big backup directory through NFS with high latency…
# removed it for now
#	docker-compose run --rm -u root elasticsearch bash -c "mkdir -p /opt/elasticsearch/backups && chown elasticsearch:root -R /opt/elasticsearch/backups"

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
	@echo "🥫 Reading logs (docker-compose) …"
	${DOCKER_COMPOSE} logs -f

#------------#
# Production #
#------------#

# Create all external volumes needed for production. Using external volumes is useful to prevent data loss (as they are not deleted when performing docker down -v)
create_external_volumes:
	docker volume create ${COMPOSE_PROJECT_NAME}_influxdb-data
	docker volume create ${COMPOSE_PROJECT_NAME}_grafana-data
	docker volume create ${COMPOSE_PROJECT_NAME}_elasticsearch-data
	docker volume create ${COMPOSE_PROJECT_NAME}_prometheus-data
	docker volume create ${COMPOSE_PROJECT_NAME}_alertmanager-data
# put backups on a shared volume
# Last volume `${COMPOSE_PROJECT_NAME}_elasticsearch-backup` is an NFS mount from the backup ZFS dataset.
# Two important notes:
# - we use `nolock` as there shouldn't be any concurrent writes on the same file, and `soft` to prevent the docker container from freezing if the NFS
#   connection is lost
# - we cannot mount directly `${NFS_VOLUMES_BACKUP_BASE_PATH}`, we have to mount a subfolder (`monitoring_elasticsearch-backup`) to prevent permission issues
	docker volume create --driver local --opt type=nfs --opt o=addr=${NFS_VOLUMES_ADDRESS},nolock,soft,rw --opt device=:${NFS_VOLUMES_BASE_PATH}/monitoring_elasticsearch-backup ${COMPOSE_PROJECT_NAME}_elasticsearch-backup

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
