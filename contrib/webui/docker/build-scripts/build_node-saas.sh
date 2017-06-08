#!/bin/sh
#
# Build script for node-sass
#
# Can take an optional parameter indicating the branch branch or tag to build
#
# 
set -x
set -e

# Set temp environment vars
export NODE_SASS_VCS_REPO=https://github.com/sass/node-sass.git
export NODE_SASS_VCS_BRANCH=master
export NODE_SASS_VCS_PATH=/tmp/node-sass

# Fetch sources from github
git clone -b ${NODE_SASS_VCS_BRANCH} --depth 1 -- ${NODE_SASS_VCS_REPO} ${NODE_SASS_VCS_PATH}
cd ${NODE_SASS_VCS_PATH}

# Compile & Install 'node-sass'
git submodule update --init --recursive
npm install
node scripts/build -f 


