
## #################################################################
## TITLE
## #################################################################

papernet.docker.all: papernet.docker.dev.zone.build papernet.docker.dist.backend.build papernet.docker.dist.frontend.build

### Common
papernet.docker.dev.zone.build: papernet.docker.dist.generated.clean papernet.docker.dev.zone.backend.build papernet.docker.dev.zone.frontend.build

### Clean
papernet.docker.dist.generated.clean: papernet.docker.dist.generated.clean.cli papernet.docker.dist.generated.clean.web papernet.docker.dist.generated.clean.front

papernet.docker.dist.generated.clean.cli:
	@rm -fR $(DIST_PATH)/cli/conf/$(APP_NAME)_self*
	@rm -fR $(DIST_PATH)/cli/conf/$(APP_NAME)_rsa*
	@rm -fR $(DIST_PATH)/cli/$(APP_NAME)_cli
	@rm -fR $(DIST_PATH)/cli/$(APP_NAME)-cli-*
	@rm -fR $(DIST_PATH)/cli/xc/*

papernet.docker.dist.generated.clean.web:
	@rm -fR $(DIST_PATH)/web/conf/$(APP_NAME)_self*
	@rm -fR $(DIST_PATH)/web/conf/$(APP_NAME)_rsa*
	@rm -fR $(DIST_PATH)/web/$(APP_NAME)_web
	@rm -fR $(DIST_PATH)/web/$(APP_NAME)-web-*
	@rm -fR $(DIST_PATH)/web/xc/*

papernet.docker.dist.generated.clean.front:
	@rm -fR $(DIST_PATH)/front/content/*

### Check generated output

### Backend
papernet.docker.dist.backend.build:	papernet.docker.dist.backend.cli.build papernet.docker.dist.backend.web.build

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

### Frontend
papernet.docker.dist.frontend.build:	
	@docker-compose -f docker-compose.yml build app

papernet.docker.dev.zone.frontend.build: 
	@echo "Running docker 'development' container for $(APP_NAME), component 'front-end'"
	@docker-compose -f docker-compose.dev.yml build $(DOCKER_BUILD_CACHE_ARG) frontend_dev

papernet.docker.dev.zone.frontend.run: 
	@echo "Running docker 'development' container for $(APP_NAME), component 'front-end'"
	@docker-compose -f docker-compose.dev.yml run frontend_dev $(DOCKERFILE_DEFAULT_ENTRYPOINT)
