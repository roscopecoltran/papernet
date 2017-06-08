
## #################################################################
## TITLE
## #################################################################

# refs:
# - https://github.com/jwilder/docker-squash

DOCKER_SQUASH_VERSION := "0.2.0"
DOCKER_SQUASH_OS  	  := "$(OS)"
DOCKER_SQUASH_ARCH	  := "$(ARCH)"

docker.squash.install.release:
	@wget https://github.com/jwilder/docker-squash/releases/download/v$(DOCKER_SQUASH_VERSION)/docker-squash-$(DOCKER_SQUASH_OS)-$(DOCKER_SQUASH_ARCH)-v$(DOCKER_SQUASH_VERSION).tar.gz
	@sudo tar -C /usr/local/bin -xzvf docker-squash-$(DOCKER_SQUASH_OS)-$(DOCKER_SQUASH_ARCH)-v$(DOCKER_SQUASH_VERSION).tar.gz

#docker.squash.container:
#	@docker save 49b5a7a88d5 | sudo docker-squash -t squash -verbose | docker load
