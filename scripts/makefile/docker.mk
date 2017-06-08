
## #################################################################
## TITLE
## #################################################################

# refs:
# - https://github.com/amalucelli/makefile-for-docker

# .PHONY: docker.build docker.test docker.pkg

SHARD=0
SHARDS=1

DOCKER_VERSION := $(shell docker --version | awk '{gsub(/,.*/,""); print $$3}')
DOCKER_MINOR_VERSION := $(shell echo '$(DOCKER_VERSION)' | awk -F'.' '{print $$2}')

# public or private docker registry
REGISTRY ?= docker.io

# version of the docker image
VERSION ?= $(shell git describe --tags --always --dirty)

# ports that docker needs to expose for a web ui container
PORTS_WEBUI ?= -p 8080:8080

# ports that docker needs to expose for a web ui container
PORTS_API ?= -p 1705:1705

# ensure that latest isn't use for build
define isLatest
	@[ $(VERSION) != "latest" ] || (echo "VERSION can't be latest in $(@)"; exit 1)
endef

UNTAGGED_IMAGES := "docker images -a | grep "none" | awk '{print $$3}'"

ifeq ($(WEBUI_HELPERS), TRUE)

# map user and group from host to container
ifeq ($(PLATFORM), OSX)
  CONTAINER_USERNAME = root
  CONTAINER_GROUPNAME = root
  HOMEDIR = /root
  CREATE_USER_COMMAND =
  COMPOSER_CACHE_DIR = ~/tmp/composer
  BOWER_CACHE_DIR = ~/tmp/bower
  GRUNT_CACHE_DIR = ~/tmp/grunt
else
  CONTAINER_USERNAME = dummy
  CONTAINER_GROUPNAME = dummy
  HOMEDIR = /home/$(CONTAINER_USERNAME)
  GROUP_ID = $(shell id -g)
  USER_ID = $(shell id -u)
  CREATE_USER_COMMAND = \
    groupadd -f -g $(GROUP_ID) $(CONTAINER_GROUPNAME) && \
    useradd -u $(USER_ID) -g $(CONTAINER_GROUPNAME) $(CONTAINER_USERNAME) && \
    mkdir -p $(HOMEDIR) &&
  COMPOSER_CACHE_DIR = /var/tmp/composer
  BOWER_CACHE_DIR = /var/tmp/bower
  GRUNT_CACHE_DIR = /var/tmp/grunt
endif

# map SSH identity from host to container
DOCKER_SSH_IDENTITY ?= ~/.ssh/id_rsa
DOCKER_SSH_KNOWN_HOSTS ?= ~/.ssh/known_hosts
ADD_SSH_ACCESS_COMMAND = \
  mkdir -p $(HOMEDIR)/.ssh && \
  test -e /var/tmp/id && cp /var/tmp/id $(HOMEDIR)/.ssh/id_rsa ; \
  test -e /var/tmp/known_hosts && cp /var/tmp/known_hosts $(HOMEDIR)/.ssh/known_hosts ; \
  test -e $(HOMEDIR)/.ssh/id_rsa && chmod 600 $(HOMEDIR)/.ssh/id_rsa ;

# utility commands
AUTHORIZE_HOME_DIR_COMMAND = chown -R $(CONTAINER_USERNAME):$(CONTAINER_GROUPNAME) $(HOMEDIR) &&
EXECUTE_AS = sudo -u $(CONTAINER_USERNAME) HOME=$(HOMEDIR)

endif


dockerfiles:=$(shell ls docker/build/*/Dockerfile)
all_images:=$(patsubst docker/build/%/Dockerfile,%,$(dockerfiles))

# Used in the test.mk file as well.
images:=$(if $(TRAVIS_COMMIT_RANGE),$(shell git diff --name-only $(TRAVIS_COMMIT_RANGE) | python util/parsefiles.py),$(all_images))

docker_build=docker.build.
docker_test=docker.test.
docker_pkg=docker.pkg.
docker_push=docker.push.

# N.B. / is used as a separator so that % will match the /
# in something like 'edxops/trusty-common:latest'
# Also, make can't handle ':' in filenames, so we instead '@'
# which means the same thing to docker
docker_pull=docker.pull/

build: docker.build

test: docker.test

pkg: docker.pkg

clean: docker.clean

docker.clean:
	rm -rf .build

docker.test.shard: $(foreach image,$(shell echo $(images) | python util/balancecontainers.py $(SHARDS) | awk 'NR%$(SHARDS)==$(SHARD)'),$(docker_test)$(image))

docker.build: $(foreach image,$(images),$(docker_build)$(image))
docker.test: $(foreach image,$(images),$(docker_test)$(image))
docker.pkg: $(foreach image,$(images),$(docker_pkg)$(image))
docker.push: $(foreach image,$(images),$(docker_push)$(image))

$(docker_pull)%:
	docker pull $(subst @,:,$*)

$(docker_build)%: docker/build/%/Dockerfile
	docker build -f $< .

$(docker_test)%: .build/%/Dockerfile.test
	docker build -t $*:test -f $< .

$(docker_pkg)%: .build/%/Dockerfile.pkg
	docker build -t $*:latest -f $< .

$(docker_push)%: $(docker_pkg)%
	docker tag $*:latest edxops/$*:latest
	docker push edxops/$*:latest

docker.is.cache:
	@echo "is docker using cache system?"
	@echo " - DOCKER_BUILD_NOCACHE=$(DOCKER_BUILD_NOCACHE)"
	@echo " - DOCKER_BUILD_CACHE_ARG=$(DOCKER_BUILD_CACHE_ARG)"

docker.clean.volumes: 
	@echo "Removing dangling volumes..."
	@docker volume rm $$(docker volume ls -qf dangling=true) && echo "Done."; \
	if [ $$? -ne 0 ]; then \
		echo "Could not find any dangling volumes. Skipping..."; \
	fi

docker.clean.images: 
	@echo "Removing untagged images..."
	@docker rmi $$($(UNTAGGED_IMAGES)) && echo "Done."; \
	if [ $$? -ne 0 ]; then \
		echo "Could not find any untagged images. Skipping..."; \
	fi

docker.clean: docker.clean.volumes docker.clean.images

#docker.pull.images:
#	for f in $(shell find ./integration/resources/compose/ -type f); do \
#		docker-compose -f $$f pull; \
#	done

.build/%/Dockerfile.d: docker/build/%/Dockerfile Makefile
	@mkdir -p .build/$*
	$(eval FROM=$(shell grep "^\s*FROM" $< | sed -E "s/FROM //" | sed -E "s/:/@/g"))
	$(eval EDXOPS_FROM=$(shell echo "$(FROM)" | sed -E "s#edxops/([^@]+)(@.*)?#\1#"))
	@echo "$(docker_build)$*: $(docker_pull)$(FROM)" > $@
	@if [ "$(EDXOPS_FROM)" != "$(FROM)" ]; then \
	echo "$(docker_test)$*: $(docker_test)$(EDXOPS_FROM:@%=)" >> $@; \
	echo "$(docker_pkg)$*: $(docker_pkg)$(EDXOPS_FROM:@%=)" >> $@; \
	else \
	echo "$(docker_test)$*: $(docker_pull)$(FROM)" >> $@; \
	echo "$(docker_pkg)$*: $(docker_pull)$(FROM)" >> $@; \
	fi

.build/%/Dockerfile.test: docker/build/%/Dockerfile Makefile
	@mkdir -p .build/$*
	@sed -E "s#FROM edxops/([^:]+)(:\S*)?#FROM \1:test#" $< > $@

.build/%/Dockerfile.pkg: docker/build/%/Dockerfile Makefile
	@mkdir -p .build/$*
	@sed -E "s#FROM edxops/([^:]+)(:\S*)?#FROM \1:test#" $< > $@

# https://github.com/jwilder/docker-squash
docker.squash: check_golang
	@go get -v github.com/jwilder/docker-squash

-include $(foreach image,$(images),.build/$(image)/Dockerfile.d)
