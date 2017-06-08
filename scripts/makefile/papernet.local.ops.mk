
## #################################################################
## TITLE
## #################################################################

## OPS
APP_OPS_DIR       		:= "contrib/ops"
APP_OPS_PATH      		:= "$(CURDIR)/$(APP_OPS_DIR)"
APP_OPS_VCS_URI   		:= "https://github.com/bobinette/papernet-ops.git"
APP_OPS_VCS_BRANCH		:= "master"

papernet.ops.add:
	@ if [ ! -d "$(APP_OPS_PATH)" ]; then \
		git subtree add --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash ; \
	  else \
		echo "Skipping request as remote repository was already added $(APP_OPS_VCS_URI)"; \
	  fi

papernet.ops.pull:
	@ if [ ! -d "$(APP_OPS_PATH)" ]; then \
		git subtree add --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash ; \
	  else \
		git subtree pull --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH) --squash ; \
	  fi

papernet.ops.push:
	@git subtree push --prefix $(APP_OPS_DIR) $(APP_OPS_VCS_URI) $(APP_OPS_VCS_BRANCH)

papernet.ops.remove:
	@rm -fR $(APP_OPS_DIR)

papernet.subtree.ops: papernet.ops.pull