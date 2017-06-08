
## #################################################################
## TITLE
## #################################################################

GIT_BRANCH := $(subst heads/,,$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null))
GIT_REPONAME := $(shell echo $(REPO) | tr '[:upper:]' '[:lower:]')

git_sm_update:
	@$(GIT_EXEC_PATH) submodule update --init --recursive

