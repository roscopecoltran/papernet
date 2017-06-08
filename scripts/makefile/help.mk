
## #################################################################
## TITLE
## #################################################################

# Rule "help"
help:
	@echo "\nUsage: make [target]\n\nTarget: \n"
	@grep -h "##" $(MAKEFILE_LIST) | grep -v "(help\|grep)" | sed -e "s/## //" -e 's/^/  /' -e 's/:/ -/'

help_awk: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

print-%: ; @echo $*=$($*)

summary:
	@echo " ------  LOCAL MACHINE  ------"
	@echo "|"
	@echo "|-- PLATFORM: $(PLATFORM)"
	@echo "|-- OS: $(OS)"
	@echo "|-- BITS: $(LBITS) bits"
	@echo "|   |-- ARCH: $(ARCH)"
	@echo "|"
	@echo "|-- HOST_NAME: $(HOST_NAME)"
	@echo "|"
	@echo "|--- LANGUAGES:" 
	@echo "|   |"
    # project_url: https://github.com/nodejs/node
	@echo "|   |-- NODEJS ? $(IS_NODEJS)"
	@ if [ "$(NODEJS_EXEC_PATH)" != "" ]; then \
	  echo "|      |    |-- Path: $(NODEJS_EXEC_PATH)"; \
	  fi

    # project_url: https://github.com/npm/npm
	@echo "|       |-- NPM ? $(IS_NPM)"
	@ if [ "$(NPM_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(NPM_EXEC_PATH)"; \
	 fi

    # project_url: https://github.com/yarnpkg/yarn
	@echo "|       |-- YARN ? $(IS_YARN)"
	@ if [ "$(YARN_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(YARN_EXEC_PATH)"; \
	 fi

	@echo "|"
    # project_url: https://golang.org/
	@echo "|       |-- GOLANG ? $(IS_GOLANG)"
	@ if [ "$(GOLANG_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(GOLANG_EXEC_PATH)"; \
	 fi

    # project_url: https://github.com/Masterminds/glide
	@echo "|       |   |-- GLIDE ? $(IS_GLIDE)"
	@ if [[ "$(GLIDE_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(GLIDE_EXEC_PATH)"; \
	 fi

    # project_url: https://github.com/mitchellh/gox
	@echo "|       |   |-- GOX ? $(IS_GOX)"
	@ if [[ "$(GOX_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(GOX_EXEC_PATH)"; \
	 fi

    # project_url: https://github.com/tools/godep
	@echo "|       |   |-- GODEP ? $(IS_GODEP)"
	@ if [[ "$(GODEP_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(GODEP_EXEC_PATH)"; \
	 fi

	@echo "|"
    # project_url: https://www.python.org
	@echo "|       |-- PYTHON2 ? $(IS_PYTHON2)"
	@ if [ "$(PYTHON2_EXEC_PATH)" != "" ]; then \
	  echo "|      |    |-- Path: $(PYTHON2_EXEC_PATH)"; \
	  fi

    # project_url: https://pypi.python.org
	@echo "|       |   |-- PIP2 ? $(IS_PIP2)"
	@ if [[ "$(PIP2_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|       |   |   |-- Path: $(PIP2_EXEC_PATH)"; \
	 fi

    # project_url: https://www.python.org
	@echo "|       |-- PYTHON3 ? $(IS_PYTHON3)"
	@ if [ "$(PYTHON3_EXEC_PATH)" != "" ]; then \
	 echo "|       |   |-- Path: $(PYTHON3_EXEC_PATH)"; \
	 fi

    # project_url: https://pypi.python.org
	@echo "|       |   |-- PIP3 ? $(IS_PIP3)"
	@ if [[ "$(PIP3_EXEC_PATH)" != ""] && ["$(GOLANG_EXEC_PATH)" != "" ]]; then \
	 echo "|           |   |-- Path: $(PIP3_EXEC_PATH)"; \
	 fi

	@echo "|"
	@echo "|--- DOCKER:" 
	@echo "|   |"
    # project_url: https://github.com/moby/moby
	@echo "|   |-- CLI ? $(IS_DOCKER)"
	@ if [ "$(DOCKER_EXEC_PATH)" != "" ]; then \
	 echo "|   |     |-- Path: $(DOCKER_EXEC_PATH)"; \
	  fi

    # project_url: https://github.com/docker/machine
	@echo "|   |-- MACHINE ? $(IS_DOCKER_MACHINE)"
	@ if [ "$(DOCKER_MACHINE_EXEC_PATH)" != "" ]; then \
	 echo "|   |     |   |-- Path: $(DOCKER_MACHINE_EXEC_PATH)"; \
	  fi

    # project_url: https://github.com/docker/swarm
	@echo "|   |-- SWARM ? $(IS_DOCKER_SWARM)"
	@ if [ "$(DOCKER_SWARM_EXEC_PATH)" != "" ]; then \
	 echo "|   |     |   |-- Path: $(DOCKER_SWARM_EXEC_PATH)"; \
	  fi

	@echo "|"
	@echo " ------  PROJECT CONFIF ------"
	@echo "|"
	@echo "|-- DOCKER WEBUI HELPERS? $(DOCKER_WEBUI_HELPERS)"


