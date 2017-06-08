
## #################################################################
## Makefile - Papernet FRONT-END 
## #################################################################

.PHONY: all

## #################################################################
## Project info/profile
## #################################################################

TEST?=./...

## local 
APP_NAME        		:= "bobinette"
APP_NAMESPACE   		:= "papernet"
APP_VCS_PROVIDER		:= "github.com"

APP_VCS_URI				:= "$(APP_VCS_PROVIDERAPP_NAMESPACE)/$(APP_NAME)"

## #################################################################
## Project docker info
## #################################################################

## docker
DOCKERFILE_DEV					:= "build.Dockerfile"

DOCKER_USERNAME=$(APP_NAMESPACE)
DOCKER_IMAGE_NAME=$(APP_NAME)
DOCKER_IMAGE_TAG=latest

UNTAGGED_IMAGES=docker images -a | grep "none" | awk '{print $$3}'

## #################################################################
## Targets - Local
## #################################################################

# local targets
default: deps build test

all: deps build test

build:
	@npm run build

lint:
	@npm run lint

dev:
	@npm run dev

mocha:
	@npm run mocha

mocha_dev:
	@npm run mocha:watch

test:
	@npm run test

targets:
	@npm run-script

deps:
	@npm install

## #################################################################
## Targets - Docker
## #################################################################

docker-build:
	@echo "Building docker image"
	@docker build -t $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)) -f Dockerfile.front --no-cache .
	@echo "Done."

docker-run: docker-build
	@echo "Running docker container for $(APP_NAME)"
	@docker run -t -i -p 0.0.0.0:8080:8080 $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
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

.PHONY: bin default test updatedeps