
## #################################################################
## TITLE
## #################################################################

#### Papernet WEB-UI
papernet.webui.add:
	@ if [ ! -d "$(APP_WEBUI_PATH)" ]; then \
		git subtree add --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_WEBUI_VCS_URI)"; \
	  fi

papernet.webui.update:
	@ if [ ! -d "$(APP_WEBUI_PATH)" ]; then \
		git subtree add --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  else \
		git subtree pull --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  fi

papernet.webui.push:
	@git subtree push --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH)

papernet.webui.docker:
	@echo "Build Docker container 'DEV' for $(APP_NAME) front-end"
	@docker-compose -f $(CURDIR)/contrib/webui/docker-compose.dev.yml build --no-cache=$(DOCKER_BUILD_NOCACHE) frontend_dev
	@echo "Building static version of $(APP_NAME) front-end"
	@docker-compose -f $(CURDIR)/contrib/webui/docker-compose.dev.yml run frontend_dev build
	@ls -l $(CURDIR)/dist/front/content
	@echo "Done."

papernet.webui.clean:
	@rm -fR $(DIST_PATH)/front/content/*
	@rm -fR $(APP_WEBUI_DIR)/app/content/*