# Rosco Pecoltran - 2017
# To do: 
# - check, test for all local, docker targets

.PHONY: all

APP_NAME := "papernet"
APP_INDEX_MAPPING_FILE := "$(CURDIR)/bleve/mapping.json"
APP_DATA_DIR := "$(CURDIR)/data"

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

SRCS = $(shell git ls-files '*.go' | grep -v '^vendor/' | grep -v '^integration/vendor/')

TEST?=./...

BIND_DIR := "dist"
PAPERNET_MOUNT := -v "$(CURDIR)/$(BIND_DIR):/go/src/github.com/bobinette/papernet/$(BIND_DIR)"

GIT_BRANCH := $(subst heads/,,$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null))

PAPERNET_DEV_IMAGE := $(APP_NAME)-dev$(if $(GIT_BRANCH),:$(subst /,-,$(GIT_BRANCH)))
REPONAME := $(shell echo $(REPO) | tr '[:upper:]' '[:lower:]')

PAPERNET_IMAGE := $(if $(REPONAME),$(REPONAME),"$(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME)")

DOCKER_RUN_OPTS := $(PAPERNET_ENVS) $(PAPERNET_MOUNT) "$(PAPERNET_DEV_IMAGE)"
DOCKER_RUN_PAPERNET := docker run $(INTEGRATION_OPTS) -it $(DOCKER_RUN_OPTS)
DOCKER_RUN_PAPERNET_NOTTY := docker run $(INTEGRATION_OPTS) -i $(DOCKER_RUN_OPTS)

# CNIP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

print-%: ; @echo $*=$($*)

# local targets
default: binary
all: deps cross

all: generate-webui build ## validate all checks, build linux binary, run all tests\ncross non-linux binaries
	$(DOCKER_RUN_PAPERNET) ./script/make.sh

generate-certs:
	@mkdir -p $(CURDIR)/certs
	@openssl req -out $(CURDIR)/certs/server.csr -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -new -newkey rsa:2048 -nodes -keyout $(CURDIR)/certs/server.key
	@openssl req -x509 -sha256 -nodes -days 365 -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -newkey rsa:2048 -keyout $(CURDIR)/certs/server.key -out $(CURDIR)/certs/server.crt
	@chmod 600 $(CURDIR)/certs/server*
	# @openssl x509 -in $(CURDIR)/certs/server.pem -text -noout

crossbinary-local: deps
	@go get -u -v github.com/mitchellh/gox	
	@gox -os="darwin linux" -arch="386 amd64" -output ./dist/{{.Dir}}/papernet-{{.OS}}-{{.Arch}}-{{.Dir}} ./cmd/...

crossbinary: generate-webui build ## cross build the non-linux binaries
	$(DOCKER_RUN_PAPERNET) ./script/make.sh generate crossbinary

crossbinary-parallel:
	$(MAKE) generate-webui
	$(MAKE) build crossbinary-default crossbinary-others

crossbinary-default: generate-webui build
	$(DOCKER_RUN_PAPERNET_NOTTY) ./script/make.sh generate crossbinary-default

crossbinary-default-parallel:
	$(MAKE) generate-webui
	$(MAKE) build crossbinary-default

crossbinary-others: generate-webui build
	$(DOCKER_RUN_PAPERNET_NOTTY) ./script/make.sh generate crossbinary-others

crossbinary-others-parallel:
	$(MAKE) generate-webui
	$(MAKE) build crossbinary-others

test: build ## run the unit and integration tests
	$(DOCKER_RUN_PAPERNET) ./script/make.sh generate test-unit binary test-integration

test-unit: build ## run the unit tests
	$(DOCKER_RUN_PAPERNET) ./script/make.sh generate test-unit

test-integration: build ## run the integration tests
	$(DOCKER_RUN_PAPERNET) ./script/make.sh generate binary test-integration

validate: build  ## validate gofmt, golint and go vet
	$(DOCKER_RUN_PAPERNET) ./script/make.sh  validate-glide validate-gofmt validate-govet validate-golint validate-misspell validate-vendor

build: dist
	docker build $(DOCKER_BUILD_ARGS) -t "$(PAPERNET_DEV_IMAGE)" -f build.Dockerfile .

#build-webui:
#	docker build -t papernet-front -f webui/Dockerfile webui

build-no-cache: dist
	docker build --no-cache -t "$(PAPERNET_DEV_IMAGE)" -f build.Dockerfile .

shell: build ## start a shell inside the build env
	$(DOCKER_RUN_PAPERNET) /bin/bash

docker-image: binary ## build a docker papernet image
	docker build -t $(PAPERNET_IMAGE) .

dist:
	mkdir dist

run-dev:
	go generate
	go build
	./traefik

generate-webui: build-webui
	if [ ! -d "static" ]; then \
		mkdir -p static; \
		docker run --rm -v "$$PWD/static":'/src/static' traefik-webui npm run build; \
		echo 'For more informations show `webui/readme.md`' > $$PWD/static/DONT-EDIT-FILES-IN-THIS-DIRECTORY.md; \
	fi

lint:
	script/validate-golint

fmt:
	gofmt -s -l -w $(SRCS)

index:
	mkdir -p $(APP_DATA_DIR)
	go run cmd/cli/*.go index create --index=$(APP_DATA_DIR)/$(APP_NAME).index --mapping=$(APP_INDEX_MAPPING_FILE)

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

test:
	@go test $(TEST) $(TESTARGS) -timeout=10s

testrace:
	@go test -race $(TEST) $(TESTARGS)

deps:
	@go get -u github.com/tools/godep
	#@dep ensure
	#@go get -u -v github.com/Masterminds/glide
	#@glide install --strip-vendor

# docker targets
docker-build:
	@echo "Building docker image for $(APP_NAME)"
	@docker build -t $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)) .
	@echo "Done."

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

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

