
## #################################################################
## TITLE
## #################################################################

## WEB-UI
APP_WEBUI_DIR       	:= "contrib/webui"
APP_WEBUI_PATH      	:= "$(CURDIR)/$(APP_WEBUI_DIR)"
APP_WEBUI_VCS_URI   	:= "https://github.com/bobinette/papernet-front.git"
APP_WEBUI_VCS_BRANCH	:= "master"

#### Papernet WEB-UI
papernet.webui.add:
	@ if [ ! -d "$(APP_WEBUI_PATH)" ]; then \
		git subtree add --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_WEBUI_VCS_URI)"; \
	  fi

papernet.webui.pull:
	@ if [ ! -d "$(APP_WEBUI_PATH)" ]; then \
		git subtree add --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  else \
		git subtree pull --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  fi

papernet.webui.push:
	@git subtree push --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH)

papernet.webui.clean:
	@rm -fR $(DIST_PATH)/front/content/*
	@rm -fR $(APP_WEBUI_DIR)/app/content/*

papernet.webui.remove:
	@rm -fR $(APP_WEBUI_DIR)

papernet.subtree.webui: papernet.webui.pull