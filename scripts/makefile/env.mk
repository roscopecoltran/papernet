
## #################################################################
## TITLE
## #################################################################

SHELL := /bin/bash

# determine platform
ifeq (Darwin, $(findstring Darwin, $(shell uname -a)))
  PLATFORM := OSX
  OS := darwin
else
  PLATFORM := Linux
  OS := $(shell echo $(PLATFORM) | tr '[:upper:]' '[:lower:]')
endif

LBITS := $(shell $(CC) $(CFLAGS) -dM -E - </dev/null | grep -q "__LP64__" && echo 64 || echo 32)

ifeq ($(LBITS), 64)
	ARCH := amd64
else ifeq ($(LBITS), 32)
	ARCH := 386
endif

GIT_EXEC_PATH := $(shell which git)
IS_GIT := $(if $(GIT_EXEC_PATH), TRUE, FALSE)

SVN_EXEC_PATH := $(shell which svn)
IS_SVN := $(if $(SVN_EXEC_PATH), TRUE, FALSE)

HG_EXEC_PATH := $(shell which hg)
IS_HG := $(if $(HG_EXEC_PATH), TRUE, FALSE)

DOCKER_EXEC_PATH := $(shell which docker)
IS_DOCKER := $(if $(DOCKER_EXEC_PATH), TRUE, FALSE)

DOCKER_MACHINE_EXEC_PATH := $(shell which docker-compose)
IS_DOCKER_MACHINE := $(if $(DOCKER_MACHINE_EXEC_PATH), TRUE, FALSE)

DOCKER_SWARM_EXEC_PATH := $(shell which docker-swarm)
IS_DOCKER_SWARM := $(if $(DOCKER_SWARM_EXEC_PATH), TRUE, FALSE)

NODEJS_EXEC_PATH := $(shell which node)
IS_NODEJS := $(if $(NODEJS_EXEC_PATH), TRUE, FALSE)

NPM_EXEC_PATH := $(shell which npm)
IS_NPM := $(if $(NPM_EXEC_PATH), TRUE, FALSE)

YARN_EXEC_PATH := $(shell which yarn)
IS_YARN := $(if $(YARN_EXEC_PATH), TRUE, FALSE)

GOLANG_EXEC_PATH := $(shell which go)
IS_GOLANG := $(if $(GOLANG_EXEC_PATH), TRUE, FALSE)

GLIDE_EXEC_PATH := $(shell which glide)
IS_GLIDE := $(if $(GLIDE_EXEC_PATH), TRUE, FALSE)

GOX_EXEC_PATH := $(shell which gox)
IS_GOX := $(if $(GOX_EXEC_PATH), TRUE, FALSE)

GODEP_EXEC_PATH := $(shell which dep)
IS_GODEP := $(if $(GODEP_EXEC_PATH), TRUE, FALSE)

PYTHON2_EXEC_PATH := $(shell which python2)
IS_PYTHON2 := $(if $(PYTHON2_EXEC_PATH), TRUE, FALSE)

PYTHON3_EXEC_PATH := $(shell which python3)
IS_PYTHON3 := $(if $(PYTHON3_EXEC_PATH), TRUE, FALSE)

PIP2_EXEC_PATH := $(shell which pip2)
IS_PIP2 := $(if $(PIP2_EXEC_PATH), TRUE, FALSE)

PIP3_EXEC_PATH := $(shell which pip3)
IS_PIP3 := $(if $(PIP3_EXEC_PATH), TRUE, FALSE)

#CONDA_EXEC_PATH := $(shell which conda)
#IS_CONDA := $(if $(CONDA_EXEC_PATH), TRUE, FALSE)

#MINICONDA_EXEC_PATH := $(shell which miniconda)
#IS_MINICONDA := $(if $(MINICONDA_EXEC_PATH), TRUE, FALSE)

HOST_NAME := $(shell hostname -f)
# CNIP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

