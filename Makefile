
## #################################################################
## Makefile - Papernet project 
## Rosco Pecoltran - 2017
## #################################################################

.PHONY: all

## #################################################################
## Project info/profile
## #################################################################

## local 
APP_NAME        		:= "papernet"
APP_NAMESPACE   		:= "bobinette"
APP_VCS_PROVIDER		:= "github.com"

APP_VCS_URI				:= "$(APP_VCS_PROVIDERAPP_NAMESPACE)/$(APP_NAME)"

APP_DATA_DIR   			:= "$(CURDIR)/data"
APP_CONTRIB_DIR			:= "$(CURDIR)/contrib"
APP_ADDONS_DIR 			:= "$(CURDIR)/addons"

TEST?=./...
BIND_DIR 				:= "dist"
BIND_PATH				:= "$(CURDIR)/$(BIND_DIR)"
DIST_PATH				:= "$(CURDIR)/$(BIND_DIR)"

SCRIPTS_PATH     		:= $(CURDIR)/scripts
CONFIG_CERTS_PATH		:= $(CURDIR)/configuration/certs

APP_INDEX_MAPPING_FILE	:= "$(CURDIR)/bleve/mapping.json"

## #################################################################
## Makefile modules
## #################################################################

## build/deploy helpers
include $(CURDIR)/scripts/makefile/env.mk
include $(CURDIR)/scripts/makefile/auth.mk
include $(CURDIR)/scripts/makefile/help.mk
include $(CURDIR)/scripts/makefile/git.mk
include $(CURDIR)/scripts/makefile/golang.mk
include $(CURDIR)/scripts/makefile/xc.mk	

## sub-projects helpers
include $(CURDIR)/scripts/makefile/contrib.mk
include $(CURDIR)/scripts/makefile/experimental.mk
include $(CURDIR)/scripts/makefile/aggregate.mk

## sub-projects experimental addons helpers
include $(CURDIR)/scripts/makefile/experimental/*.mk

## sub-projects (official) addons helpers
include $(CURDIR)/scripts/makefile/papernet.*.mk

## #################################################################
## Project docker info
## #################################################################

## docker
DOCKERFILE_DEV					:= "build.Dockerfile"

DOCKERFILE_DEFAULT_ENTRYPOINT	:= "bashpp"

# scratch, true, alpine
DOCKERFILE_BACKEND_BASE_DIST	:= "scratch" 
DOCKERFILE_BACKEND_CLI_DIST 	:= "dist/cli/Dockerfile.$(DOCKERFILE_BACKEND_BASE_DIST)"
DOCKERFILE_BACKEND_WEB_DIST 	:= "dist/web/Dockerfile.$(DOCKERFILE_BACKEND_BASE_DIST)"

DOCKER_BUILD_NOCACHE  			:= false
DOCKER_BUILD_CACHE_ARG			:= $(if $(filter $(DOCKER_BUILD_NOCACHE),true), --no-cache)

DOCKER_USERNAME  				:= "$(APP_NAMESPACE)"
DOCKER_IMAGE_NAME				:= "$(APP_NAME)"
DOCKER_IMAGE_TAG 				:= "latest"

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
include $(CURDIR)/scripts/makefile/docker.machine.mk

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

# https://newfivefour.com/git-subtree-basics.html


contribs-import: webui-add ops-add

addons-import: readeef-add searx-add elasticfeed-add krakend-add
	
addons-update: readeef-update searx-update elasticfeed-update krakend-update

docker.is.cache:
	@echo "is docker using cache system?"
	@echo " - DOCKER_BUILD_NOCACHE=$(DOCKER_BUILD_NOCACHE)"
	@echo " - DOCKER_BUILD_CACHE_ARG=$(DOCKER_BUILD_CACHE_ARG)"

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

papernet.fetch.contribs: papernet.webui.fetch papernet.ops.fetch

docker.build.all: papernet.webui.add papernet.ops.add
	@echo "Building docker dev image for $(APP_NAME) / backend (cache? $(DOCKER_BUILD_NOCACHE))"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) backend_dev
	@docker-compose -f docker-compose.yml build cli
	@docker-compose -f docker-compose.yml build web
	@echo "Building docker dev image for $(APP_NAME) / frontend (cache? $(DOCKER_BUILD_NOCACHE))"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) frontend_dev
	@echo "Done."

docker.compose.build.dev: 
	@echo "Building docker dev image for $(APP_NAME) / backend (cache? $(DOCKER_BUILD_NOCACHE))"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) backend_dev
	@echo "Building docker dev image for $(APP_NAME) / frontend (cache? $(DOCKER_BUILD_NOCACHE))"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) frontend_dev

docker.compose.build.dist: 
	@docker-compose -f docker-compose.yml build cli
	@docker-compose -f docker-compose.yml build web
	@docker-compose -f docker-compose.yml build front

docker-run:
	@echo "Running docker container for $(APP_NAME)"
	@docker run -t -i -v ${APP_DATA_DIR}:/data -p 0.0.0.0:1705:1705 $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
	@echo "Done."

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

