
## #################################################################
## TITLE
## #################################################################

# Examples:
# - make papernet.docker.compose.all DOCKER_BUILD_NOCACHE=false
# - make papernet.docker.compose.dev.all DOCKER_BUILD_NOCACHE=false
# - make papernet.docker.compose.dist.all
# - make papernet.docker.compose.check.all

## #################################################################
## COMMON
## #################################################################
papernet.docker.compose.all: docker.is.cache papernet.docker.compose.dev.all papernet.docker.compose.dist.all

# papernet.docker.compose.dev.all: papernet.docker.compose.dist.generated.cleanup papernet.docker.compose.dev.zone.backend.build papernet.docker.compose.dev.zone.frontend.build
papernet.docker.compose.dev.all: docker.is.cache papernet.docker.compose.dev.zone.backend.build papernet.docker.compose.dev.zone.frontend.build

# papernet.docker.compose.dist.all: papernet.docker.compose.dist.generated.cleanup papernet.docker.compose.dist.backend.build papernet.docker.compose.dist.frontend.build
papernet.docker.compose.dist.all: docker.is.cache papernet.docker.compose.dist.backend.wrap papernet.docker.compose.dist.backend.build papernet.docker.compose.dist.frontend.build

## #################################################################
## BACK-END
## #################################################################
papernet.docker.compose.dist.backend.wrap: papernet.docker.compose.dev.zone.backend.build papernet.docker.compose.dist.backend.cli.wrap papernet.docker.compose.dist.backend.web.wrap

papernet.docker.compose.dist.backend.cli.wrap:
	@docker-compose -f docker-compose.yml build $(DOCKER_BUILD_CACHE_ARG) cli

papernet.docker.compose.dist.backend.web.wrap:
	@docker-compose -f docker-compose.yml build $(DOCKER_BUILD_CACHE_ARG) web

papernet.docker.compose.dev.zone.backend.build:
	@echo "Running docker 'development' container for $(APP_NAME), component 'back-end'"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) backend_dev

papernet.docker.compose.dev.zone.backend.run:
	@echo "Running docker 'development' container for $(APP_NAME), component 'back-end'"
	@docker-compose -f docker-compose.dev.yml run backend_dev $(DOCKERFILE_DEFAULT_ENTRYPOINT)

## #################################################################
## FRONT-END
## #################################################################
papernet.docker.compose.dist.frontend.build:
	@docker-compose -f docker-compose.yml build app

papernet.docker.compose.dev.zone.frontend.build:
	@echo "Running docker 'development' container for $(APP_NAME), component 'front-end'"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) frontend_dev

papernet.docker.compose.dev.zone.frontend.run:
	@echo "Running docker 'development' container for $(APP_NAME), component 'front-end'"
	@docker-compose -f docker-compose.dev.yml run frontend_dev $(DOCKERFILE_DEFAULT_ENTRYPOINT)

## #################################################################
## CHECK
## #################################################################
papernet.docker.compose.dist.generated.check:
	@echo "to do"

## #################################################################
## CLEAN
## #################################################################
papernet.docker.compose.dist.generated.cleanup.cli:
	@rm -fR $(DIST_PATH)/cli/conf/$(APP_NAME)_self*
	@rm -fR $(DIST_PATH)/cli/conf/$(APP_NAME)_rsa*
	@rm -fR $(DIST_PATH)/cli/$(APP_NAME)_cli
	@rm -fR $(DIST_PATH)/cli/$(APP_NAME)-cli-*
	@rm -fR $(DIST_PATH)/cli/xc/*

papernet.docker.compose.dist.generated.cleanup.web:
	@rm -fR $(DIST_PATH)/web/conf/$(APP_NAME)_self*
	@rm -fR $(DIST_PATH)/web/conf/$(APP_NAME)_rsa*
	@rm -fR $(DIST_PATH)/web/$(APP_NAME)_web
	@rm -fR $(DIST_PATH)/web/$(APP_NAME)-web-*
	@rm -fR $(DIST_PATH)/web/xc/*

papernet.docker.compose.dist.generated.cleanup.front:
	@mv $(DIST_PATH)/front/content $(DIST_PATH)/front/content.old
	@mkdir -p $(DIST_PATH)/front/content
	@rm -fR $(DIST_PATH)/front/content.old

papernet.docker.compose.dist.generated.cleanup: papernet.docker.compose.dist.generated.cleanup.cli papernet.docker.compose.dist.generated.cleanup.web papernet.docker.compose.dist.generated.cleanup.front


