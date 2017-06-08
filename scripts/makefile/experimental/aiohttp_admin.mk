
## #################################################################
## TITLE
## project_vcs_uri: https://github.com/aio-libs/aiohttp_admin
## #################################################################

## Addon - KRAKEND
APP_ADDON_AIOHTTP_ADMIN_DIR       		:= "aiohttp_admin"
APP_ADDON_AIOHTTP_ADMIN_PATH      		:= "$(APP_ADDONS_DIR)/$(APP_ADDON_KRAKEND_DIR)"
APP_ADDON_AIOHTTP_ADMIN_VCS_URI   		:= "https://github.com/aio-libs/aiohttp_admin.git"
APP_ADDON_AIOHTTP_ADMIN_VCS_BRANCH		:= "master"

project.aiohttp_admin.add:
	@ if [ ! -d "$(APP_ADDON_ELASTICFEED_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_AIOHTTP_ADMIN_DIR) $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI) $(APP_ADDON_AIOHTTP_ADMIN_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI)"; \
	  fi

project.aiohttp_admin.update:
	@git subtree pull --prefix $(APP_ADDON_AIOHTTP_ADMIN_DIR) $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI) $(APP_ADDON_AIOHTTP_ADMIN_VCS_BRANCH) --squash

project.aiohttp_admin.push:
	@git subtree push --prefix $(APP_ADDON_AIOHTTP_ADMIN_DIR) $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI) $(APP_ADDON_AIOHTTP_ADMIN_VCS_BRANCH)
