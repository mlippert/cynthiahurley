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

GIT_TAG_VERSION = $(shell git describe)
export GIT_TAG_VERSION

COMPOSE = podman-compose

LINT_LOG := logs/lint.log
TEST_LOG := logs/test.log

# Add --quiet to only report on errors, not warnings
ESLINT_OPTIONS = --ext .js --ext .jsx
ESLINT_FORMAT = stylish

# docker-compose database service names so they can be started individually
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

# The pull-images target is a helper to update the base docker images used
# by the edu stack services. This is a list of those base images.
BASE_IMAGES := \
	mariadb:latest \
	mysql:latest \
	mongo:latest


.DEFAULT_GOAL := help
.DELETE_ON_ERROR :
.PHONY : all up down up-mariadb up-mysql up-mongo help

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

build : lint ## build the analyze-data
	@echo "No building is currently needed to run analyze-data"

lint : ## run lint over all python source updating the .lint files
	@$(MAKE) -C pysrc lint

lint-log : ESLINT_OPTIONS += --output-file $(LINT_LOG) ## run eslint concise diffable output to $(LINT_LOG)
lint-log : ESLINT_FORMAT = unix
vim-lint : ESLINT_FORMAT = unix ## run eslint in format consumable by vim quickfix
eslint : ## run lint over the sources & tests; display results to stdout
eslint vim-lint lint-log :
	$(ESLINT) $(ESLINT_OPTIONS) --format $(ESLINT_FORMAT) src

test : ## (Not implemented) run the unit tests
	@echo test would run "$(MOCHA) --reporter spec test | tee $(TEST_LOG)"

clean : clean-build ## remove ALL created artifacts

clean-build : ## remove all artifacts created by the build target
	@$(MAKE) -C pysrc clean-build

clean-lintlog :
	@rm $(LINT_LOG) 2> /dev/null || true

outdated : ## check for newer versions of required python packages
	$(call ndef,VIRTUAL_ENV)
	pip list --outdated

upgrade-deps : ## upgrade to the latest versions of required python packages
	$(call ndef,VIRTUAL_ENV)
	pip install --upgrade -r requirements.txt

upgrade-pip : ## upgrade pip and setuptools
	$(call ndef,VIRTUAL_ENV)
	pip install --upgrade pip setuptools

up : up-mariadb ## run $(COMPOSE) up (w/ dev config)

up-mariadb : ## run $(COMPOSE) up $(MARIADB_SERVICE)
	$(COMPOSE) up --detach $(OPTS) $(MARIADB_SERVICE)

up-prod : ## run docker-compose up (w/ prod config)
	docker-compose $(COMPOSE_CONF_PROD) up --detach $(OPTS)

down : ## run docker-compose down
	docker-compose down

stop : ## run docker-compose stop
	docker-compose stop

logs : ## run docker-compose logs
	docker-compose logs $(OPTS) $(SERVICE_NAME)

pull-images : ## Update base docker images
	echo $(BASE_IMAGES) | xargs -n 1 docker pull
	docker images

clean-dev-images : down ## remove dev docker images
	docker rmi 127.0.0.1:5000/rifflearning/{pfm-riffrtc:dev,pfm-riffdata:dev,pfm-signalmaster:dev,pfm-web:dev}

show-ps : ## Show all docker containers w/ limited fields
	docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}'

## Help documentation à la https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
## if you want the help sorted rather than in the order of occurrence, pipe the grep to sort and pipe that to awk
help :
	@echo ""                                                                   ; \
	echo "Useful targets in this analyze-data Makefile:"                       ; \
	(grep -E '^[a-zA-Z_-]+ ?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " ?:.*?## "}; {printf "\033[36m%-20s\033[0m : %s\n", $$1, $$2}') ; \
	echo ""                                                                    ; \
	echo "If VIRTUAL_ENV needs to be set for a target, run '. activate' first" ; \
	echo ""
