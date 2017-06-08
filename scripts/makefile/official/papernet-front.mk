
## #################################################################
## TITLE
## #################################################################

#### Papernet WEB-UI
webui-add:
	@ if [ ! -d "$(APP_WEBUI_PATH)" ]; then \
		git subtree add --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_WEBUI_VCS_URI)"; \
	  fi

webui-update:
	@git subtree pull --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH) --squash

webui-push:
	@git subtree push --prefix $(APP_WEBUI_DIR) $(APP_WEBUI_VCS_URI) $(APP_WEBUI_VCS_BRANCH)

