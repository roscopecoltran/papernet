#!/bin/sh

PAPERNET_FRONT_SRC=/www/papernet-front
PAPERNET_FRONT_BUILD=${PAPERNET_FRONT_SRC}/app
PAPERNET_FRONT_PATH=/www/public

echo "updating papernet-front"

(cd "${PAPERNET_FRONT_SRC}" && yarn install && yarn run build)

cp -Ruf "${PAPERNET_FRONT_BUILD}/." "${PAPERNET_FRONT_PATH}/"