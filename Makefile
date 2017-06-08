# Rosco Pecoltran - 2017
# To do: 
# - check, test for all local, docker targets

.PHONY: all

APP_NAME := "papernet"
APP_INDEX_MAPPING_FILE := "$(CURDIR)/bleve/mapping.json"
APP_DATA_DIR := "$(CURDIR)/data"

## #################################################################
## Papernet - Contributions
## #################################################################

## WEB-UI
APP_WEBUI_DIR       	:= "contrib/webui"
APP_WEBUI_PATH      	:= "$(CURDIR)/$(APP_WEBUI_DIR)"
APP_WEBUI_VCS_URI   	:= "https://github.com/bobinette/papernet-front.git"
APP_WEBUI_VCS_BRANCH	:= "master"

## OPS
APP_OPS_DIR       		:= "contrib/ops"
APP_OPS_PATH      		:= "$(CURDIR)/$(APP_OPS_DIR)"
APP_OPS_VCS_URI   		:= "https://github.com/bobinette/papernet-ops.git"
APP_OPS_VCS_BRANCH		:= "master"

## #################################################################
## Papernet - Non-official addons (experiments)
## #################################################################

## Addon - SEARX
APP_ADDON_SEARX_DIR       		:= "addons/searx"
APP_ADDON_SEARX_PATH      		:= "$(CURDIR)/$(APP_ADDON_SEARX_DIR)"
APP_ADDON_SEARX_VCS_URI   		:= "https://github.com/asciimoo/searx.git"
APP_ADDON_SEARX_VCS_BRANCH		:= "master"

## Addon - READEEF
APP_ADDON_READEEF_DIR       		:= "addons/readeef"
APP_ADDON_READEEF_PATH      		:= "$(CURDIR)/$(APP_ADDON_READEEF_DIR)"
APP_ADDON_READEEF_VCS_URI   		:= "https://github.com/urandom/readeef.git"
APP_ADDON_READEEF_VCS_BRANCH		:= "master"

## Addon - ELASTICFEED
APP_ADDON_ELASTICFEED_DIR       		:= "addons/elasticfeed"
APP_ADDON_ELASTICFEED_PATH      		:= "$(CURDIR)/$(APP_ADDON_ELASTICFEED_DIR)"
APP_ADDON_ELASTICFEED_VCS_URI   		:= "https://github.com/feedlabs/elasticfeed.git"
APP_ADDON_ELASTICFEED_VCS_BRANCH		:= "master"

## Addon - KRAKEND
APP_ADDON_KRAKEND_DIR       		:= "addons/krakend"
APP_ADDON_KRAKEND_PATH      		:= "$(CURDIR)/$(APP_ADDON_KRAKEND_DIR)"
APP_ADDON_KRAKEND_VCS_URI   		:= "https://github.com/devopsfaith/krakend.git"
APP_ADDON_KRAKEND_VCS_BRANCH		:= "master"

UNTAGGED_IMAGES := "docker images -a | grep "none" | awk '{print $$3}'"
DOCKER_USERNAME := "bobinette"
DOCKER_IMAGE_NAME := "papernet"
DOCKER_IMAGE_TAG := "latest"

PAPERNET_ENVS := \
	-e OS_ARCH_ARG \
	-e OS_PLATFORM_ARG \
	-e TESTFLAGS \
	-e VERBOSE \
	-e VERSION \
	-e CODENAME \
	-e TESTDIRS \
	-e CI

SHELL := /bin/bash
# .PHONY: help requirements clean build test pkg

# include $(CURDIR)/scripts/makefile/*.mk

# determine platform
ifeq (Darwin, $(findstring Darwin, $(shell uname -a)))
  PLATFORM := OSX
  OS := darwin
else
  PLATFORM := Linux
  OS := $(shell echo $(PLATFORM) | tr '[:upper:]' '[:lower:]')
endif

LBITS := $(shell $(CC) $(CFLAGS) -dM -E - </dev/null | grep -q "__LP64__" && echo 64 || echo 32)

ifeq ($(LBITS), 64)
	ARCH := amd64
else ifeq ($(LBITS), 32)
	ARCH := 386
endif

DOCKER_WEBUI_HELPERS := FALSE

ifeq ($(WEBUI_HELPERS), TRUE)

# map user and group from host to container
ifeq ($(PLATFORM), OSX)
  CONTAINER_USERNAME = root
  CONTAINER_GROUPNAME = root
  HOMEDIR = /root
  CREATE_USER_COMMAND =
  COMPOSER_CACHE_DIR = ~/tmp/composer
  BOWER_CACHE_DIR = ~/tmp/bower
  GRUNT_CACHE_DIR = ~/tmp/grunt
else
  CONTAINER_USERNAME = dummy
  CONTAINER_GROUPNAME = dummy
  HOMEDIR = /home/$(CONTAINER_USERNAME)
  GROUP_ID = $(shell id -g)
  USER_ID = $(shell id -u)
  CREATE_USER_COMMAND = \
    groupadd -f -g $(GROUP_ID) $(CONTAINER_GROUPNAME) && \
    useradd -u $(USER_ID) -g $(CONTAINER_GROUPNAME) $(CONTAINER_USERNAME) && \
    mkdir -p $(HOMEDIR) &&
  COMPOSER_CACHE_DIR = /var/tmp/composer
  BOWER_CACHE_DIR = /var/tmp/bower
  GRUNT_CACHE_DIR = /var/tmp/grunt
endif

# map SSH identity from host to container
DOCKER_SSH_IDENTITY ?= ~/.ssh/id_rsa
DOCKER_SSH_KNOWN_HOSTS ?= ~/.ssh/known_hosts
ADD_SSH_ACCESS_COMMAND = \
  mkdir -p $(HOMEDIR)/.ssh && \
  test -e /var/tmp/id && cp /var/tmp/id $(HOMEDIR)/.ssh/id_rsa ; \
  test -e /var/tmp/known_hosts && cp /var/tmp/known_hosts $(HOMEDIR)/.ssh/known_hosts ; \
  test -e $(HOMEDIR)/.ssh/id_rsa && chmod 600 $(HOMEDIR)/.ssh/id_rsa ;

# utility commands
AUTHORIZE_HOME_DIR_COMMAND = chown -R $(CONTAINER_USERNAME):$(CONTAINER_GROUPNAME) $(HOMEDIR) &&
EXECUTE_AS = sudo -u $(CONTAINER_USERNAME) HOME=$(HOMEDIR)

endif

SRCS = $(shell git ls-files '*.go' | grep -v '^vendor/' | grep -v '^integration/vendor/')

TEST?=./...

BIND_DIR := "dist"
BIND_PATH := "$(CURDIR)/dist"

PAPERNET_MOUNT := -v "$(CURDIR)/$(BIND_DIR):/go/src/github.com/bobinette/papernet/$(BIND_DIR)"

GIT_BRANCH := $(subst heads/,,$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null))

PAPERNET_DEV_IMAGE := $(APP_NAME)-dev$(if $(GIT_BRANCH),:$(subst /,-,$(GIT_BRANCH)))
REPONAME := $(shell echo $(REPO) | tr '[:upper:]' '[:lower:]')

PAPERNET_IMAGE := $(if $(REPONAME),$(REPONAME),"$(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME)")

DOCKER_RUN_OPTS := $(PAPERNET_ENVS) $(PAPERNET_MOUNT) "$(PAPERNET_DEV_IMAGE)"
DOCKER_RUN_PAPERNET := docker run $(INTEGRATION_OPTS) -it $(DOCKER_RUN_OPTS)
DOCKER_RUN_PAPERNET_NOTTY := docker run $(INTEGRATION_OPTS) -i $(DOCKER_RUN_OPTS)

DOCKERFILE_DEV := "build.Dockerfile"

# scratch, true, alpine
DOCKERFILE_BACKEND_BASE_DIST := "scratch" 
DOCKERFILE_BACKEND_CLI_DIST := "dist/cli/Dockerfile.$(DOCKERFILE_BACKEND_BASE_DIST)"
DOCKERFILE_BACKEND_WEB_DIST := "dist/web/Dockerfile.$(DOCKERFILE_BACKEND_BASE_DIST)"

DOCKER_BUILD_NOCACHE := FALSE

SCRIPTS_PATH := $(CURDIR)/scripts
CONFIG_CERTS_PATH := $(CURDIR)/configuration/certs

DOCKER_EXEC_PATH := $(shell which docker)
IS_DOCKER := $(if $(DOCKER_EXEC_PATH), TRUE, FALSE)

DOCKER_MACHINE_EXEC_PATH := $(shell which docker-compose)
IS_DOCKER_MACHINE := $(if $(DOCKER_MACHINE_EXEC_PATH), TRUE, FALSE)

DOCKER_SWARM_EXEC_PATH := $(shell which docker-swarm)
IS_DOCKER_SWARM := $(if $(DOCKER_SWARM_EXEC_PATH), TRUE, FALSE)

NODEJS_EXEC_PATH := $(shell which node)
IS_NODEJS := $(if $(NODEJS_EXEC_PATH), TRUE, FALSE)

NPM_EXEC_PATH := $(shell which npm)
IS_NPM := $(if $(NPM_EXEC_PATH), TRUE, FALSE)

YARN_EXEC_PATH := $(shell which yarn)
IS_YARN := $(if $(YARN_EXEC_PATH), TRUE, FALSE)

GOLANG_EXEC_PATH := $(shell which go)
IS_GOLANG := $(if $(GOLANG_EXEC_PATH), TRUE, FALSE)

GLIDE_EXEC_PATH := $(shell which glide)
IS_GLIDE := $(if $(GLIDE_EXEC_PATH), TRUE, FALSE)

GOX_EXEC_PATH := $(shell which gox)
IS_GOX := $(if $(GOX_EXEC_PATH), TRUE, FALSE)

GODEP_EXEC_PATH := $(shell which dep)
IS_GODEP := $(if $(GODEP_EXEC_PATH), TRUE, FALSE)

PYTHON2_EXEC_PATH := $(shell which python2)
IS_PYTHON2 := $(if $(PYTHON2_EXEC_PATH), TRUE, FALSE)

PYTHON3_EXEC_PATH := $(shell which python3)
IS_PYTHON3 := $(if $(PYTHON3_EXEC_PATH), TRUE, FALSE)

PIP2_EXEC_PATH := $(shell which pip2)
IS_PIP2 := $(if $(PIP2_EXEC_PATH), TRUE, FALSE)

PIP3_EXEC_PATH := $(shell which pip3)
IS_PIP3 := $(if $(PIP3_EXEC_PATH), TRUE, FALSE)

#CONDA_EXEC_PATH := $(shell which conda)
#IS_CONDA := $(if $(CONDA_EXEC_PATH), TRUE, FALSE)

#MINICONDA_EXEC_PATH := $(shell which miniconda)
#IS_MINICONDA := $(if $(MINICONDA_EXEC_PATH), TRUE, FALSE)

HOST_NAME := $(shell hostname -f)
# CNIP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

print-%: ; @echo $*=$($*)

# local targets
default: binary
all: deps cross

summary:
	@echo " ------  LOCAL MACHINE  ------"
	@echo "|"
	@echo "|-- PLATFORM: $(PLATFORM)"
	@echo "|-- OS: $(OS)"
	@echo "|-- BITS: $(LBITS) bits"
	@echo "|   |-- ARCH: $(ARCH)"
	@echo "|"
	@echo "|-- HOST_NAME: $(HOST_NAME)"
	@echo "|"
	@echo "|--- LANGUAGES:" 
	@echo "|   |"
  # project_url: https://github.com/nodejs/node
	@echo "|   |-- NODEJS ? $(IS_NODEJS)"
	@ if [ "$(NODEJS_EXEC_PATH)" != "" ]; then \
	  echo "|      |    |-- Path: $(NODEJS_EXEC_PATH)"; \
	  fi

  # project_url: https://github.com/npm/npm
	@echo "|       |-- NPM ? $(IS_NPM)"
	@ if [ "$(NPM_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(NPM_EXEC_PATH)"; \
	 fi

  # project_url: https://github.com/yarnpkg/yarn
	@echo "|       |-- YARN ? $(IS_YARN)"
	@ if [ "$(YARN_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(YARN_EXEC_PATH)"; \
	 fi

	@echo "|"
  # project_url: https://golang.org/
	@echo "|       |-- GOLANG ? $(IS_GOLANG)"
	@ if [ "$(GOLANG_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(GOLANG_EXEC_PATH)"; \
	 fi

  # project_url: https://github.com/Masterminds/glide
	@echo "|       |   |-- GLIDE ? $(IS_GLIDE)"
	@ if [[ "$(GLIDE_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(GLIDE_EXEC_PATH)"; \
	 fi

  # project_url: https://github.com/mitchellh/gox
	@echo "|       |   |-- GOX ? $(IS_GOX)"
	@ if [[ "$(GOX_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(GOX_EXEC_PATH)"; \
	 fi

  # project_url: https://github.com/tools/godep
	@echo "|       |   |-- GODEP ? $(IS_GODEP)"
	@ if [[ "$(GODEP_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(GODEP_EXEC_PATH)"; \
	 fi

	@echo "|"
  # project_url: https://www.python.org
	@echo "|       |-- PYTHON2 ? $(IS_PYTHON2)"
	@ if [ "$(PYTHON2_EXEC_PATH)" != "" ]; then \
	  echo "|      |    |-- Path: $(PYTHON2_EXEC_PATH)"; \
	  fi

  # project_url: https://pypi.python.org
	@echo "|       |   |-- PIP2 ? $(IS_PIP2)"
	@ if [[ "$(PIP2_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(PIP2_EXEC_PATH)"; \
	 fi

  # project_url: https://www.python.org
	@echo "|       |-- PYTHON3 ? $(IS_PYTHON3)"
	@ if [ "$(PYTHON3_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(PYTHON3_EXEC_PATH)"; \
	 fi

  # project_url: https://pypi.python.org
	@echo "|       |   |-- PIP3 ? $(IS_PIP3)"
	@ if [[ "$(PIP3_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|           |   |-- Path: $(PIP3_EXEC_PATH)"; \
	 fi

	@echo "|"
	@echo "|--- DOCKER:" 
	@echo "|   |"
  # project_url: https://github.com/moby/moby
	@echo "|   |-- CLI ? $(IS_DOCKER)"
	@ if [ "$(DOCKER_EXEC_PATH)" != "" ]; then \
	 echo "|   |     |-- Path: $(DOCKER_EXEC_PATH)"; \
	  fi

  # project_url: https://github.com/docker/machine
	@echo "|   |-- MACHINE ? $(IS_DOCKER_MACHINE)"
	@ if [ "$(DOCKER_MACHINE_EXEC_PATH)" != "" ]; then \
	 echo "|   |     |   |-- Path: $(DOCKER_MACHINE_EXEC_PATH)"; \
	  fi

  # project_url: https://github.com/docker/swarm
	@echo "|   |-- SWARM ? $(IS_DOCKER_SWARM)"
	@ if [ "$(DOCKER_SWARM_EXEC_PATH)" != "" ]; then \
	 echo "|   |     |   |-- Path: $(DOCKER_SWARM_EXEC_PATH)"; \
	  fi

	@echo "|"
	@echo " ------  PROJECT CONFIF ------"
	@echo "|"
	@echo "|-- DOCKER WEBUI HELPERS? $(DOCKER_WEBUI_HELPERS)"

#all: generate-webui build ## validate all checks, build linux binary, run all tests\ncross non-linux binaries
#	$(DOCKER_RUN_PAPERNET) $(SCRIPTS_PATH)/make.sh

generate-certs:
	@mkdir -p $(CONFIG_CERTS_PATH)
	@openssl req -out $(CURDIR)/certs/server.csr -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -new -newkey rsa:2048 -nodes -keyout $(CURDIR)/certs/server.key
	@openssl req -x509 -sha256 -nodes -days 365 -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -newkey rsa:2048 -keyout $(CURDIR)/certs/server.key -out $(CURDIR)/certs/server.crt
	@chmod 600 $(CURDIR)/certs/server*
	# @openssl x509 -in $(CURDIR)/certs/server.pem -text -noout

crossbinary-local: deps
	@go get -u -v github.com/mitchellh/gox	
	@gox -os="darwin linux" -arch="386 amd64" -output $(BIND_PATH)/{{.Dir}}/papernet-{{.OS}}-{{.Arch}}-{{.Dir}} ./cmd/...

crossbinary: generate-webui build ## cross build the non-linux binaries
	$(DOCKER_RUN_PAPERNET) $(SCRIPTS_PATH)/make.sh generate crossbinary

crossbinary-parallel:
	$(MAKE) generate-webui
	$(MAKE) build crossbinary-default crossbinary-others

crossbinary-default: generate-webui build
	$(DOCKER_RUN_PAPERNET_NOTTY) $(SCRIPTS_PATH)/make.sh generate crossbinary-default

crossbinary-default-parallel:
	$(MAKE) generate-webui
	$(MAKE) build crossbinary-default

crossbinary-others: generate-webui build
	$(DOCKER_RUN_PAPERNET_NOTTY) $(SCRIPTS_PATH)/make.sh generate crossbinary-others

crossbinary-others-parallel:
	$(MAKE) generate-webui
	$(MAKE) build crossbinary-others

test: build ## run the unit and integration tests
	$(DOCKER_RUN_PAPERNET) $(SCRIPTS_PATH)/make.sh generate test-unit binary test-integration

test-unit: build ## run the unit tests
	$(DOCKER_RUN_PAPERNET) $(SCRIPTS_PATH)/make.sh generate test-unit

test-integration: build ## run the integration tests
	$(DOCKER_RUN_PAPERNET) $(SCRIPTS_PATH)/make.sh generate binary test-integration

validate: build  ## validate gofmt, golint and go vet
	$(DOCKER_RUN_PAPERNET) $(SCRIPTS_PATH)/make.sh  validate-glide validate-gofmt validate-govet validate-golint validate-misspell validate-vendor

build: dist
	docker build $(DOCKER_BUILD_ARGS) -t "$(PAPERNET_DEV_IMAGE)" -f $(DOCKERFILE_DEV) .

#build-webui:
#	docker build -t papernet-front -f webui/Dockerfile webui

build-no-cache: dist
	docker build --no-cache -t "$(PAPERNET_DEV_IMAGE)" -f $(DOCKERFILE_DEV) .

shell: build ## start a shell inside the build env
	$(DOCKER_RUN_PAPERNET) /bin/bash

#docker-image: binary ## build a docker papernet image
#	docker build -t $(PAPERNET_IMAGE) .

dist:
	@mkdir -p $(BIND_PATH)

lint:
	script/validate-golint

fmt:
	gofmt -s -l -w $(SRCS)

index:
	mkdir -p $(APP_DATA_DIR)
	go run cmd/cli/*.go index create --index=$(APP_DATA_DIR)/$(APP_NAME).index --mapping=$(APP_INDEX_MAPPING_FILE)

# https://newfivefour.com/git-subtree-basics.html


contribs-import: webui-add ops-add

addons-import: readeef-add searx-add elasticfeed-add krakend-add
	
addons-update: readeef-update searx-update elasticfeed-update krakend-update

# https://github.com/feedlabs/elasticfeed

#### KRAKEND
krakend-add:
	@ if [ ! -d "$(APP_ADDON_KRAKEND_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_KRAKEND_DIR) $(APP_ADDON_KRAKEND_VCS_URI) $(APP_ADDON_KRAKEND_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_KRAKEND_VCS_URI)"; \
	  fi

krakend-update:
	@git subtree pull --prefix $(APP_ADDON_KRAKEND_DIR) $(APP_ADDON_KRAKEND_VCS_URI) $(APP_ADDON_KRAKEND_VCS_BRANCH) --squash

krakend-push:
	@git subtree push --prefix $(APP_ADDON_KRAKEND_DIR) $(APP_ADDON_KRAKEND_VCS_URI) $(APP_ADDON_KRAKEND_VCS_BRANCH)

#### ELASTICFEED
elasticfeed-add:
	@ if [ ! -d "$(APP_ADDON_ELASTICFEED_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_ELASTICFEED_DIR) $(APP_ADDON_ELASTICFEED_VCS_URI) $(APP_ADDON_ELASTICFEED_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_ELASTICFEED_VCS_URI)"; \
	  fi

elasticfeed-update:
	@git subtree pull --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH) --squash

elasticfeed-push:
	@git subtree push --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH)

#### READEEF
readeef-add:
	@ if [ ! -d "$(APP_ADDON_READEEF_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_READEEF_VCS_URI)"; \
	  fi

readeef-update:
	@git subtree pull --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH) --squash

readeef-push:
	@git subtree push --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH)

#### SEARX
searx-add:
	@ if [ ! -d "$(APP_ADDON_SEARX_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_SEARX_DIR) $(APP_ADDON_SEARX_VCS_URI) $(APP_ADDON_SEARX_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_SEARX_VCS_URI)"; \
	  fi

searx-update:
	@git subtree pull --prefix $(APP_ADDON_SEARX_DIR) $(APP_ADDON_SEARX_VCS_URI) $(APP_ADDON_SEARX_VCS_BRANCH) --squash

searx-push:
	@git subtree push --prefix $(APP_ADDON_SEARX_DIR) $(APP_ADDON_SEARX_VCS_URI) $(APP_ADDON_SEARX_VCS_BRANCH)

#### WEB-UI
webui-add:
	@ if [ ! -d "$(APP_WEBUI_PATH)" ]; then \
		git subtree add --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_WEBUI_VCS_URI)"; \
	  fi

webui-update:
	@git subtree pull --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash

webui-push:
	@git subtree push --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH)

#### OPS
ops-add:
	@ if [ ! -d "$(APP_OPS_PATH)" ]; then \
		git subtree add --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_OPS_VCS_URI)"; \
	  fi

ops-update:
	@git subtree pull --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash

ops-push:
	@git subtree push --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH)

#generate-webui: build-webui
#	if [ ! -d "static" ]; then \
#		mkdir -p static; \
#		docker run --rm -v "$$PWD/static":'/src/static' traefik-webui npm run build; \
#		echo 'For more informations show `webui/readme.md`' > $$PWD/static/DONT-EDIT-FILES-IN-THIS-DIRECTORY.md; \
#	fi

clean_all: clean_bin clean_data # clean_deps

clean_bin:
	@rm -fR $(CURDIR)/$(BIND_DIR)
	@mkdir -p $(CURDIR)/$(BIND_DIR)

clean_data:
	@rm -fR $(APP_DATA_DIR)
	@mkdir -p $(APP_DATA_DIR)

binary:
	@mkdir -p ./$(BIND_DIR)
	@go build -o ./$(BIND_DIR)/web/papernet_web cmd/web/main.go
	@go build -o ./$(BIND_DIR)/cli/papernet_cli cmd/cli/*.go

#dev:
#	@TF_DEV=1 sh -c "$(CURDIR)/docker/build.sh"

test-local:
	@go test $(TEST) $(TESTARGS) -timeout=10s

testrace:
	@go test -race $(TEST) $(TESTARGS)

deps:
	@go get -u github.com/tools/godep
	#@dep ensure
	#@go get -u -v github.com/Masterminds/glide
	#@glide install --strip-vendor

# docker targets
docker-all: webui-add ops-add
	@echo "Building docker image for $(APP_NAME)"
	@docker-compose -f docker-compose.dev.yml build --no-cache backend_dev
	@docker-compose -f docker-compose.dev.yml run backend_dev
	@docker-compose -f docker-compose.yml build cli
	@docker-compose -f docker-compose.yml build web
	@docker-compose -f $(CURDIR)/contrib/webui/docker-compose.dev.yml build --no-cache frontend_dev
	@docker-compose -f $(CURDIR)/contrib/webui/docker-compose.dev.yml run frontend_dev
	#@docker-compose -f docker-compose.yml build web
	@echo "Done."

docker-run:
	@echo "Running docker container for $(APP_NAME)"
	@docker run -t -i -v ${APP_DATA_DIR}:/data -p 0.0.0.0:1705:1705 $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
	@echo "Done."

# dcb: docker-compose-backend
dcb-dev:
	@echo "Running docker `development` container for $(APP_NAME), component `back-end`"
	@docker-compose -f docker-compose.dev.yml run backend_dev

# dcb: docker-compose-frontend
dcf-dev:
	@echo "Running docker `development` container for $(APP_NAME), component `front-end`"
	@docker-compose -f docker-compose.dev.yml run frontend_dev

docker-remove:
	@echo "Removing existing docker image"
	@docker rmi $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
	@echo "Done."

docker-rebuild: docker-remove docker-build

docker-publish: docker-build
	@echo "Publishing image to artifactory..."
	@docker push $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
	@echo "Done."

docker-clean-volumes:
	@echo "Removing dangling volumes..."
	@docker volume rm $$(docker volume ls -qf dangling=true) && echo "Done."; \
	if [ $$? -ne 0 ]; then \
		echo "Could not find any dangling volumes. Skipping..."; \
	fi

docker-clean-images:
	@echo "Removing untagged images..."
	@docker rmi $$($(UNTAGGED_IMAGES)) && echo "Done."; \
	if [ $$? -ne 0 ]; then \
		echo "Could not find any untagged images. Skipping..."; \
	fi

docker-clean: docker-clean-volumes docker-clean-images

docker-pull-images:
	for f in $(shell find ./integration/resources/compose/ -type f); do \
		docker-compose -f $$f pull; \
	done

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

