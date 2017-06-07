#!/bin/sh

set -e

if [ $# -eq 0 ] ; then
	echo "Usage: ./gen-dockerfile.sh <papernet tag or branch>"
	exit
fi

export VERSION=${1:-0.9.1}

# cd to the current directory so the script can be run from anywhere.
cd `dirname $0`

# create certs and conf folders for 'API' container (dist version)
mkdir -p ./dist/web/certs
mkdir -p ./dist/web/conf

# Update the certificates.
echo "Updating certificates..."
./scripts/gen-certificates.sh

echo "Fetching and building papernet $VERSION..."
rm -f ./bleve/mapping.json
rm -f ./data/mapping.json
rm -f ./dist/web/papernet-linux-amd64-web
rm -f ./dist/cli/papernet-linux-amd64-cli
wget -O mapping.json -P ./bleve https://github.com/bobinette/papernet/releases/download/${VERSION}/mapping.json
wget -O mapping.json -P ./data https://github.com/bobinette/papernet/releases/download/${VERSION}/mapping.json
wget -O papernet-linux-amd64-cli -P ./dist/cli https://github.com/bobinette/papernet/releases/download/${VERSION}/papernet-linux-amd64-cli
wget -O papernet-linux-amd64-web -P ./dist/web https://github.com/bobinette/papernet/releases/download/${VERSION}/papernet-linux-amd64-web
chmod +x ./dist/cli/papernet-linux-amd64-cli
chmod +x ./dist/cli/papernet-linux-amd64-web

echo "Replace $VERSION in Dockerfiles..."
envsubst < ./docker/Dockerfile.tmpl > ./dist/cli/Dockerfile
envsubst < ./docker/Dockerfile.tmpl > ./dist/web/Dockerfile
cp -f ./bleve/mapping.json ./dist/cli/
cp -f ./bleve/mapping.json ./dist/web/

echo "Done."
