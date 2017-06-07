#!/bin/sh
set -x
set -e

# Set temp environment vars
export GIFSCILE_VCS_REPO=https://github.com/kohler/gifsicle.git
export GIFSCILE_VCS_BRANCH=master
export GIFSCILE_VCS_PATH=/tmp/gifsicle

# Fetch sources from github
git clone -b ${GIFSCILE_VCS_BRANCH} --depth 1 -- ${GIFSCILE_VCS_REPO} ${GIFSCILE_VCS_PATH}
cd ${GIFSCILE_VCS_PATH}

# Compile & Install 'gifsicle'
./bootstrap.sh
./configure
make -j3
make install

# Cleanup
rm -fR ${GIFSCILE_VCS_PATH}