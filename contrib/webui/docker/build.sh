#!/bin/sh

# Rosco Pecoltran - 2017

set -x
set -e

# Install build deps
apk update

apk --no-cache --no-progress --virtual BUILD add ${ALPINE_PKG_BUILD}
apk --no-cache --no-progress --virtual RUNTIME add ${ALPINE_PKG_RUNTIME}
apk --no-cache --no-progress --virtual INTERACTIVE add ${ALPINE_PKG_INTERACTIVE}

# Install gifsicle
# ./docker/build-gifsicle.sh

# Install node-saas
# ./docker/build_node-saas.sh

# Install yarn + webpack
# npm install -g node-gyp webpack webpack-dev-server yarn modclean
# npm install -g modclean

# Install NPM dependencies
# yarn install
npm install


npm run build

# Remove stack of deps 'BUILD'
apk --no-cache --no-progress del BUILD

# Remove build deps
#for STACK_NAME in ${ALPINE_PKG_DEL_STACKS[@]}; do
#  apk --no-cache --no-progress del ${STACK_NAME}
#done