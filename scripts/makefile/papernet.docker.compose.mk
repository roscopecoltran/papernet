
## #################################################################
## TITLE
## #################################################################

# Examples:
# - make papernet.docker.all DOCKER_BUILD_NOCACHE=false
# - make papernet.docker.dev.all DOCKER_BUILD_NOCACHE=false
# - make papernet.docker.dist.all
# - make papernet.docker.check.all

## #################################################################
## COMMON
## #################################################################
papernet.docker.all: docker.is.cache papernet.docker.dev.all papernet.docker.dist.all

# papernet.docker.dev.all: papernet.docker.dist.generated.cleanup papernet.docker.dev.zone.backend.build papernet.docker.dev.zone.frontend.build
papernet.docker.dev.all: docker.is.cache papernet.docker.dev.zone.backend.build papernet.docker.dev.zone.frontend.build

# papernet.docker.dist.all: papernet.docker.dist.generated.cleanup papernet.docker.dist.backend.build papernet.docker.dist.frontend.build
papernet.docker.dist.all: docker.is.cache papernet.docker.dist.backend.build papernet.docker.dist.frontend.build

## #################################################################
## BACK-END
## #################################################################
papernet.docker.dist.backend.build: papernet.docker.dist.backend.cli.build papernet.docker.dist.backend.web.build

papernet.docker.dist.backend.cli.build:
	@docker-compose -f docker-compose.yml build $(DOCKER_BUILD_CACHE_ARG) cli

papernet.docker.dist.backend.web.build:
	@docker-compose -f docker-compose.yml build $(DOCKER_BUILD_CACHE_ARG) web

papernet.docker.dev.zone.backend.build:
	@echo "Running docker 'development' container for $(APP_NAME), component 'back-end'"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) backend_dev

papernet.docker.dev.zone.backend.run:
	@echo "Running docker 'development' container for $(APP_NAME), component 'back-end'"
	@docker-compose -f docker-compose.dev.yml run backend_dev $(DOCKERFILE_DEFAULT_ENTRYPOINT)

## #################################################################
## FRONT-END
## #################################################################
papernet.docker.dist.frontend.build:
	@docker-compose -f docker-compose.yml build app

papernet.docker.dev.zone.frontend.build:
	@echo "Running docker 'development' container for $(APP_NAME), component 'front-end'"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) frontend_dev

papernet.docker.dev.zone.frontend.run:
	@echo "Running docker 'development' container for $(APP_NAME), component 'front-end'"
	@docker-compose -f docker-compose.dev.yml run frontend_dev $(DOCKERFILE_DEFAULT_ENTRYPOINT)

## #################################################################
## CHECK
## #################################################################
papernet.docker.dist.generated.check:
	@echo "to do"

## #################################################################
## CLEAN
## #################################################################
papernet.docker.dist.generated.cleanup.cli:
	@rm -fR $(DIST_PATH)/cli/conf/$(APP_NAME)_self*
	@rm -fR $(DIST_PATH)/cli/conf/$(APP_NAME)_rsa*
	@rm -fR $(DIST_PATH)/cli/$(APP_NAME)_cli
	@rm -fR $(DIST_PATH)/cli/$(APP_NAME)-cli-*
	@rm -fR $(DIST_PATH)/cli/xc/*

papernet.docker.dist.generated.cleanup.web:
	@rm -fR $(DIST_PATH)/web/conf/$(APP_NAME)_self*
	@rm -fR $(DIST_PATH)/web/conf/$(APP_NAME)_rsa*
	@rm -fR $(DIST_PATH)/web/$(APP_NAME)_web
	@rm -fR $(DIST_PATH)/web/$(APP_NAME)-web-*
	@rm -fR $(DIST_PATH)/web/xc/*

papernet.docker.dist.generated.cleanup.front:
	@mv $(DIST_PATH)/front/content $(DIST_PATH)/front/content.old
	@mkdir -p $(DIST_PATH)/front/content
	@rm -fR $(DIST_PATH)/front/content.old

papernet.docker.dist.generated.cleanup: papernet.docker.dist.generated.cleanup.cli papernet.docker.dist.generated.cleanup.web papernet.docker.dist.generated.cleanup.front


