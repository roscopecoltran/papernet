
## #################################################################
## TITLE
## project_vcs_uri: https://github.com/aio-libs/aiohttp_admin
## #################################################################

aiohttp_admin-add:
	@ if [ ! -d "$(APP_ADDON_ELASTICFEED_PATH)" ]; then \
		git subtree add --prefix $(APP_ADDON_AIOHTTP_ADMIN_DIR) $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI) $(APP_ADDON_AIOHTTP_ADMIN_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI)"; \
	  fi

aiohttp_admin-update:
	@git subtree pull --prefix $(APP_ADDON_AIOHTTP_ADMIN_DIR) $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI) $(APP_ADDON_AIOHTTP_ADMIN_VCS_BRANCH) --squash

aiohttp_admin-push:
	@git subtree push --prefix $(APP_ADDON_AIOHTTP_ADMIN_DIR) $(APP_ADDON_AIOHTTP_ADMIN_VCS_URI) $(APP_ADDON_AIOHTTP_ADMIN_VCS_BRANCH)
