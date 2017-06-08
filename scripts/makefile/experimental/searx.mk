
## #################################################################
## TITLE
## #################################################################

## Addon - SEARX
APP_ADDON_SEARX_DIR       		:= "searx"
APP_ADDON_SEARX_PATH      		:= "$(APP_ADDONS_DIR)/$(APP_ADDON_SEARX_DIR)"
APP_ADDON_SEARX_VCS_URI   		:= "https://github.com/asciimoo/searx.git"
APP_ADDON_SEARX_VCS_BRANCH		:= "master"

project.searx.add:
	@ if [ ! -d "$(APP_ADDON_SEARX_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_SEARX_DIR) $(APP_ADDON_SEARX_VCS_URI) $(APP_ADDON_SEARX_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_SEARX_VCS_URI)"; \
	  fi

project.searx.update:
	@git subtree pull --prefix $(APP_ADDON_SEARX_DIR) $(APP_ADDON_SEARX_VCS_URI) $(APP_ADDON_SEARX_VCS_BRANCH) --squash

project.searx.push:
	@git subtree push --prefix $(APP_ADDON_SEARX_DIR) $(APP_ADDON_SEARX_VCS_URI) $(APP_ADDON_SEARX_VCS_BRANCH)

