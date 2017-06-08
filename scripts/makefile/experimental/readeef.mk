
## #################################################################
## TITLE
## #################################################################

project.readeef.add:
	@ if [ ! -d "$(APP_ADDON_READEEF_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_READEEF_VCS_URI)"; \
	  fi

project.readeef.update:
	@git subtree pull --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH) --squash

project.readeef.push:
	@git subtree push --prefix $(APP_ADDON_READEEF_DIR) $(APP_ADDON_READEEF_VCS_URI) $(APP_ADDON_READEEF_VCS_BRANCH)

