#!/usr/bin/env bash

#### halt script on error
set -xe

echo '##### Print docker version'
docker --version

echo '##### Print environment'
env | sort

#### Build the Docker Images
cat .env
docker-compose -f docker-compose.yml -f docker-compose.dev.yml build ${BUILD_SERVICE}
docker images
