#
# Makefile to for various actions related to database work for Cynthia Hurley Fine Wines
#

# force the shell used to be bash in case for some commands we want to use
# set -o pipefail ex:
#    set -o pipefail ; SOMECOMMAND 2>&1 | tee $(LOG_FILE)
SHELL := /bin/bash

# Test if a variable has a value, callable from a recipe
# like $(call ndef,ENV)
ndef = $(if $(value $(1)),,$(error $(1) not set))

# NOTE: we're not using the git tag for anything right now, so disable this so it doesn't HAVE to exist
#GIT_TAG_VERSION = $(shell git describe)
#export GIT_TAG_VERSION

CNTR_CLI := podman
COMPOSE = podman-compose

# docker-compose database service names so they can be brought up and down individually
MARIADB_SERVICE := chw-mariadb
MYSQL_SERVICE   := chw-mysql
MONGODB_SERVICE := chw-mongo

# The order to combine the compose/stack config files for spinning up
# the riff services using either docker-compose or docker stack
# for development, production or deployment in a docker swarm
CONF_BASE   := docker-compose.yml
CONF_DEV    := $(CONF_BASE)
CONF_PROD   := $(CONF_BASE)
CONF_DEPLOY := $(CONF_PROD) docker-stack.yml

COMPOSE_CONF_DEV := $(patsubst %,-f %,$(CONF_DEV))
COMPOSE_CONF_PROD := $(patsubst %,-f %,$(CONF_PROD))
STACK_CONF_DEPLOY := $(patsubst %,-c %,$(CONF_DEPLOY))

# The pull-images target is a helper to update the base container images used in this Makefile
BASE_IMAGES := \
	mariadb:latest \
	mysql:latest \
	mongo:latest


.DEFAULT_GOAL := help
.DELETE_ON_ERROR :
.PHONY : run init install up down up-mariadb down-mariadb up-mysql down-mysql up-mongo down-mongo help

run : ## run the main python script
	$(call ndef,VIRTUAL_ENV)
	python pysrc/main.py

init : install build ## run install, build; intended for initializing a fresh repo clone

install : VER ?= 3
install : ## create python3 virtual env, install requirements (define VER for other than python3)
	@python$(VER) -m venv venv
	@ln -s venv/bin/activate activate
	@source activate                        ; \
	pip install --upgrade pip setuptools    ; \
	pip install -r requirements.txt

build : lint ## build the chwdata cli
	@echo "No building is currently needed to run the chwdata cli"

lint : ## run lint over all python source updating the .lint files
	@$(MAKE) -C pysrc lint

test : ## (Not implemented) run the unit tests
	@$(MAKE) -C pysrc test

clean : clean-build ## remove ALL created artifacts

clean-build : ## remove all artifacts created by the build target
	@$(MAKE) -C pysrc clean-build

outdated : ## check for newer versions of required python packages
	$(call ndef,VIRTUAL_ENV)
	pip list --outdated

upgrade-deps : ## upgrade to the latest versions of required python packages
	$(call ndef,VIRTUAL_ENV)
	pip install --upgrade -r requirements.txt

upgrade-pip : ## upgrade pip and setuptools
	$(call ndef,VIRTUAL_ENV)
	pip install --upgrade pip setuptools

up : up-mariadb ## run up-mariadb

down : down-mariadb ## run down-mariadb

up-mariadb : ## run $(COMPOSE) up $(MARIADB_SERVICE)
	$(COMPOSE) up --detach $(OPTS) $(MARIADB_SERVICE)

down-mariadb : ## run $(COMPOSE) down $(MARIADB_SERVICE)
	$(COMPOSE) down $(OPTS) $(MARIADB_SERVICE)

up-mysql : ## run $(COMPOSE) up $(MYSQL_SERVICE)
	$(COMPOSE) up --detach $(OPTS) $(MYSQL_SERVICE)

down-mysql : ## run $(COMPOSE) down $(MYSQL_SERVICE)
	$(COMPOSE) down $(OPTS) $(MYSQL_SERVICE)

up-mongo : ## run $(COMPOSE) up $(MONGODB_SERVICE)
	$(COMPOSE) up --detach $(OPTS) $(MONGODB_SERVICE)

down-mongo : ## run $(COMPOSE) down $(MONGODB_SERVICE)
	$(COMPOSE) down $(OPTS) $(MONGODB_SERVICE)

up-prod : ## run docker-compose up (w/ prod config)
	docker-compose $(COMPOSE_CONF_PROD) up --detach $(OPTS)

stop : ## run $(COMPOSE) stop $(SERVICE_NAME)
	$(COMPOSE) stop $(SERVICE_NAME)

logs : ## run docker-compose logs $(SERVICE_NAME)
	$(COMPOSE) logs $(OPTS) $(SERVICE_NAME)

pull-images : ## Update base docker images
	echo $(BASE_IMAGES) | xargs -n 1 $(CNTR_CLI) pull
	$(CNTR_CLI) images

show-ps : ## Show all docker containers w/ limited fields
	$(CNTR_CLI) ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}'

## Help documentation à la https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
## if you want the help sorted rather than in the order of occurrence, pipe the grep to sort and pipe that to awk
help :
	@echo ""                                                                   ; \
	echo "Useful targets in this CHW data Makefile:"                           ; \
	(grep -E '^[a-zA-Z_-]+ ?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " ?:.*?## "}; {printf "\033[36m%-20s\033[0m : %s\n", $$1, $$2}') ; \
	echo ""                                                                    ; \
	echo "If VIRTUAL_ENV needs to be set for a target, run '. activate' first" ; \
	echo ""
