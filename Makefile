.PHONY: all

## #################################################################
## Makefile - Papernet project 
## #################################################################

## project vcs info 
APP_NAME        		:= "papernet"
APP_NAMESPACE   		:= "bobinette"
APP_VCS_PROVIDER		:= "github.com"
APP_VCS_URI     		:= "$(APP_VCS_PROVIDERAPP_NAMESPACE)/$(APP_NAME)"

## project dirs & config files
APP_DATA_DIR          	:= "$(CURDIR)/data"
APP_CONTRIB_DIR       	:= "$(CURDIR)/contrib"
APP_ADDONS_DIR        	:= "$(CURDIR)/addons"
APP_INDEX_MAPPING_FILE	:= "$(CURDIR)/bleve/mapping.json"

# network settings
APP_API_HOST  			:= 0.0.0.0
APP_API_PORT  			:= 1705
APP_FRONT_HOST			:= 0.0.0.0
APP_FRONT_PORT			:= 8080

# compile info
TEST?=./...
BIND_DIR 				:= "dist"
BIND_PATH				:= "$(CURDIR)/$(BIND_DIR)"
DIST_PATH				:= "$(CURDIR)/$(BIND_DIR)"

# helpers dirs
SCRIPTS_PATH			:= $(CURDIR)/scripts

# certs, auth files dirs
CONFIG_CERTS_PATH		:= $(CURDIR)/configuration/certs

## #################################################################
## Makefile modules
## #################################################################

## build/deploy helpers
include $(CURDIR)/scripts/makefile/env.mk
include $(CURDIR)/scripts/makefile/certs.mk
include $(CURDIR)/scripts/makefile/help.mk
include $(CURDIR)/scripts/makefile/git.mk
include $(CURDIR)/scripts/makefile/golang.mk
include $(CURDIR)/scripts/makefile/xc.mk	

## sub-projects experimental addons helpers
include $(CURDIR)/scripts/makefile/experimental/*.mk

## sub-projects (official) addons helpers
include $(CURDIR)/scripts/makefile/papernet.*.mk

## #################################################################
## Project docker info
## #################################################################

## docker
DOCKER_BUILD_NOCACHE			:= false
DOCKER_IMAGE_TAG 				:= "latest"
DOCKERFILE_DEV               	:= "build.Dockerfile"
DOCKERFILE_DEFAULT_ENTRYPOINT	:= "bashplus"

DOCKERFILE_BACKEND_BASE_DIST	:= "scratch" 
DOCKERFILE_BACKEND_CLI_DIST 	:= "dist/cli/Dockerfile.$(DOCKERFILE_BACKEND_BASE_DIST)"
DOCKERFILE_BACKEND_WEB_DIST 	:= "dist/web/Dockerfile.$(DOCKERFILE_BACKEND_BASE_DIST)"

DOCKER_BUILD_CACHE_ARG			:= $(if $(filter $(DOCKER_BUILD_NOCACHE),true), --no-cache)

DOCKER_USERNAME  				:= "$(APP_NAMESPACE)"
DOCKER_IMAGE_NAME				:= "$(APP_NAME)"

DOCKER_ENVS := \
	-e OS_ARCH_ARG \
	-e OS_PLATFORM_ARG \
	-e TESTFLAGS \
	-e VERBOSE \
	-e VERSION \
	-e CODENAME \
	-e TESTDIRS \
	-e CI

APP_MOUNT    			:= -v "$(CURDIR)/$(BIND_DIR):/go/src/$(APP_VCS_URI)/$(BIND_DIR)"
APP_DEV_IMAGE			:= $(APP_NAME)-dev$(if $(GIT_BRANCH),:$(subst /,-,$(GIT_BRANCH)))
APP_IMAGE    			:= $(if $(REPONAME),$(REPONAME),"$(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME)")

DOCKER_RUN_OPTS     	:= $(PAPERNET_ENVS) $(PAPERNET_MOUNT) "$(PAPERNET_DEV_IMAGE)"
DOCKER_RUN_APP      	:= docker run $(INTEGRATION_OPTS) -it $(DOCKER_RUN_OPTS)
DOCKER_RUN_APP_NOTTY	:= docker run $(INTEGRATION_OPTS) -i $(DOCKER_RUN_OPTS)

## sub-projects (official) addons helpers
# include $(CURDIR)/scripts/makefile/docker*.mk
# include $(CURDIR)/scripts/makefile/docker.machine.mk

# local targets
default: binary
all: deps cross

dist:
	@mkdir -p $(BIND_PATH)

lint:
	script/validate-golint

fmt:
	gofmt -s -l -w $(SRCS)

index:
	mkdir -p $(APP_DATA_DIR)
	go run cmd/cli/*.go index create --index=$(APP_DATA_DIR)/$(APP_NAME).index --mapping=$(APP_INDEX_MAPPING_FILE)

docker.is.cache:
	@echo "is docker using cache system?"
	@echo " - DOCKER_BUILD_NOCACHE=$(DOCKER_BUILD_NOCACHE)"
	@echo " - DOCKER_BUILD_CACHE_ARG=$(DOCKER_BUILD_CACHE_ARG)"

clean_all: clean_bin clean_data # clean_deps

clean_bin:
	@rm -fR $(CURDIR)/$(BIND_DIR)
	@mkdir -p $(CURDIR)/$(BIND_DIR)

clean_data:
	@rm -fR $(APP_DATA_DIR)
	@mkdir -p $(APP_DATA_DIR)

binary:
	@mkdir -p ./$(BIND_DIR)
	@go build -o ./$(BIND_DIR)/web/$(APP_NAME)_web cmd/web/main.go
	@go build -o ./$(BIND_DIR)/cli/$(APP_NAME)_cli cmd/cli/*.go

test-local:
	@go test $(TEST) $(TESTARGS) -timeout=10s

testrace:
	@go test -race $(TEST) $(TESTARGS)

deps:
	@go get -u github.com/tools/godep
	@dep ensure

deps.glide:
	@go get -u -v github.com/Masterminds/glide
	@glide install --strip-vendor

