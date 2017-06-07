#/bin/sh

CURRENT_DIR=$(pwd)
cd ..

docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
