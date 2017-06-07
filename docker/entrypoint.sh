#!/bin/sh
set -x
set -e

echo "ENTRY_POINT_MODE: ${ENTRY_POINT_MODE}"
echo "ENTRY_POINT_MODE: ${ENTRY_POINT_MODE}"
echo "ARG1: ${1}"

if [ "$ENTRY_POINT_MODE" == "" ];then
	CASE=${ENTRY_POINT_MODE}
else
	CASE=${1}
fi

GIT_COMMIT=$(git rev-parse HEAD)
GIT_DIRTY=$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)

case "$CASE" in

	'xc')

		gox -os="linux darwin" -arch="amd64" -ldflags "-X main.GitCommit ${GIT_COMMIT}${GIT_DIRTY}" -output /dist/crossbuild/{{.OS}}/{{.Dir}}/${APP_NAME}-{{.OS}}-{{.Arch}}-{{.Dir}} $(glide novendor)
		cp -f /dist/linux/cli/crossbuild/${APP_NAME}-linux-amd64-cli /dist/cli/${APP_NAME}-linux-amd64-cli
		cp -f /dist/linux/web/crossbuild/${APP_NAME}-linux-amd64-web /dist/web/${APP_NAME}-linux-amd64-web

		if [ "$ENTRYPOINT_MODE" == "build_run" ];then	
		  exec go /dist/${APP_NAME}-linux-amd64-cli $@
		fi

	;;

	'cli')
		if [ "$ENTRYPOINT_MODE" == "build_run" ];then	
			GOOS=linux GOARCH=amd64 go build -ldflags "-X main.GitCommit ${GIT_COMMIT}${GIT_DIRTY}" -o /dist/${APP_NAME}-linux-amd64-cli cmd/cli/*.go
			exec go /dist/${APP_NAME}-linux-amd64-cli $@
		else
			exec go run cmd/web/main.go $@
		fi
	;;

	'web')

		if [ "$ENTRYPOINT_MODE" == "build_run" ];then	
			GOOS=linux GOARCH=amd64 go build -ldflags "-X main.GitCommit ${GIT_COMMIT}${GIT_DIRTY}" -o /dist/${APP_NAME}-linux-amd64-web cmd/web/main.go
			exec go /dist/${APP_NAME}-linux-amd64-web $@
		else
		  	exec go run cmd/web/main.go $@
		fi	

	;;

	'index')
		if [ "$ENTRYPOINT_MODE" == "build_run" ];then
			GOOS=linux GOARCH=amd64 go build -ldflags "-X main.GitCommit ${GIT_COMMIT}${GIT_DIRTY}" -o /dist/${APP_NAME}-linux-amd64-cli cmd/cli/*.go
			exec go /dist/${APP_NAME}-linux-amd64-cli index create --index=${APP_DATA_DIR:-"/data"}/${APP_NAME}.index --mapping=${APP_INDEX_MAPPING_FILE:-"bleve/mapping.json"}
		else
			exec go run cmd/cli/*.go index create --index=${APP_DATA_DIR:-"/data"}/${APP_NAME}.index --mapping=${APP_INDEX_MAPPING_FILE:-"bleve/mapping.json"}
		fi
	;;

	'bash')
		exec /bin/bash $@

	;;

	'test')
		exec go test $(go list ./... | grep -v /vendor/)
	;;

	*)

		exec sh $@
	;;

esac
