#!/usr/bin/env bash
set -e

if [ -n "$TRAVIS_COMMIT" ]; then
  echo "Deploying PR..."
else
  echo "Skipping deploy PR"
  exit 0
fi

# create docker image bobinette/papernet
echo "Updating docker bobinette/papernet image..."
docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
docker tag bobinette/papernet bobinette/papernet:${TRAVIS_COMMIT}
docker push bobinette/papernet:${TRAVIS_COMMIT}
docker tag bobinette/papernet bobinette/papernet:experimental
docker push bobinette/papernet:experimental

echo "Deployed"
