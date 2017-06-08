
## #################################################################
## TITLE
## #################################################################

xc-local: deps
	@go get -u -v github.com/mitchellh/gox	
	@gox -os="darwin linux" -arch="386 amd64" -output $(DIST_PATH)/{{.Dir}}/$(APP_NAME)-{{.OS}}-{{.Arch}}-{{.Dir}} ./cmd/...

xc: generate-webui build ## cross build the non-linux binaries
	$(DOCKER_RUN_PAPERNET) $(SCRIPTS_PATH)/make.sh generate xc

xc-parallel:
	$(MAKE) generate-webui
	$(MAKE) build xc-default xc-others

xc-default: generate-webui build
	$(DOCKER_RUN_CONTAINER_NOTTY) $(SCRIPTS_PATH)/make.sh generate xc-default

xc-default-parallel:
	$(MAKE) generate-webui
	$(MAKE) build xc-default

xc-others: generate-webui build
	$(DOCKER_RUN_CONTAINER_NOTTY) $(SCRIPTS_PATH)/make.sh generate xc-others

xc-others-parallel:
	$(MAKE) generate-webui
	$(MAKE) build xc-others

test: build ## run the unit and integration tests
	$(DOCKER_RUN_CONTAINER) $(SCRIPTS_PATH)/make.sh generate test-unit binary test-integration

test-unit: build ## run the unit tests
	$(DOCKER_RUN_CONTAINER) $(SCRIPTS_PATH)/make.sh generate test-unit

test-integration: build ## run the integration tests
	$(DOCKER_RUN_CONTAINER) $(SCRIPTS_PATH)/make.sh generate binary test-integration

validate: build  ## validate gofmt, golint and go vet
	$(DOCKER_RUN_CONTAINER) $(SCRIPTS_PATH)/make.sh  validate-glide validate-gofmt validate-govet validate-golint validate-misspell validate-vendor

build: dist
	docker build $(DOCKER_BUILD_ARGS) -t "$(DOCKER_DEV_IMAGE)" -f $(DOCKERFILE_DEV) .

#build-webui:
#	docker build -t papernet-front -f webui/Dockerfile webui

build-no-cache: dist
	docker build --no-cache -t "$(DOCKER_DEV_IMAGE)" -f $(DOCKERFILE_DEV) .

shell: build ## start a shell inside the build env
	$(DOCKER_RUN_CONTAINER) /bin/bash
