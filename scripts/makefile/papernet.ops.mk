
## #################################################################
## TITLE
## #################################################################

papernet.ops.add:
	@ if [ ! -d "$(APP_OPS_PATH)" ]; then \
		git subtree add --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_OPS_VCS_URI)"; \
	  fi

papernet.ops.update:
	@ if [ ! -d "$(APP_OPS_PATH)" ]; then \
		git subtree add --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash ; \
	  else \
		git subtree pull --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash ; \
	  fi

papernet.ops.push:
	@git subtree push --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH)

