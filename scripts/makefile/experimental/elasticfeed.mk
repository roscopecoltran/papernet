
## #################################################################
## TITLE
## #################################################################

## Addon - ELASTICFEED
APP_ADDON_ELASTICFEED_DIR       		:= "elasticfeed"
APP_ADDON_ELASTICFEED_PATH      		:= "$(APP_ADDONS_DIR)/$(APP_ADDON_ELASTICFEED_DIR)"
APP_ADDON_ELASTICFEED_VCS_URI   		:= "https://github.com/feedlabs/elasticfeed.git"
APP_ADDON_ELASTICFEED_VCS_BRANCH		:= "master"

project.elasticfeed.add:
	@ if [ ! -d "$(APP_ADDON_ELASTICFEED_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_ELASTICFEED_DIR) $(APP_ADDON_ELASTICFEED_VCS_URI) $(APP_ADDON_ELASTICFEED_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_ELASTICFEED_VCS_URI)"; \
	  fi

project.elasticfeed.update:
	@git subtree pull --prefix $(APP_ADDON_ELASTICFEED_DIR) $(APP_ADDON_ELASTICFEED_VCS_URI) $(APP_ADDON_ELASTICFEED_VCS_BRANCH) --squash

project.elasticfeed.push:
	@git subtree push --prefix $(APP_ADDON_ELASTICFEED_DIR) $(APP_ADDON_ELASTICFEED_VCS_URI) $(APP_ADDON_ELASTICFEED_VCS_BRANCH)

