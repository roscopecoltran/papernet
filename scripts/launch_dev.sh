#/bin/sh

CURRENT_DIR=$(pwd)
PARENT_DIR=$(basename ${CURRENT_DIR})

echo "CURRENT_DIR: ${CURRENT_DIR}"
echo "PARENT_DIR: ${PARENT_DIR}"

docker-compose -f docker-compose.dev.yml up
#docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
