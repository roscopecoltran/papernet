#!/bin/sh
set -x
set -e

if [ "$ENTRYPOINT_MODE" == "" ];then
	CASE=${ENTRYPOINT_MODE}
else
	CASE=${1}
	ENTRYPOINT_ARGS=${@:2}
fi

export APP_CERTIFICATES="/app/configuration/certs"
export APP_SSL_SELFSIGNED_BASENAME="${PROJECT_NAME}_self-signed"

export APP_WEB="/dist/web/xc/linux/${PROJECT_NAME}-linux-amd64-web"
export APP_CLI="/dist/cli/xc/linux/${PROJECT_NAME}-linux-amd64-cli"

if [ -f "${APP_CLI}" ];then
	mkdir -p /dist/cli
	cp ${APP_CLI} /dist/cli/${PROJECT_NAME}_cli
fi

if [ -f "${APP_WEB}" ];then
	mkdir -p /dist/web
	cp ${APP_WEB} /dist/web/${PROJECT_NAME}_web
fi

if [ -d "/tmp/go" ];then
	export GOPATH=/tmp/go
	export PATH=${PATH}:${GOPATH}/bin
	export PROJECT_SOURCE_PATH=${GOPATH}/src/${PROJECT_VCS_PROVIDER}/${PROJECT_NAMESPACE}/${PROJECT_NAME}
fi

if [ "$ENTRYPOINT_ECHO" == true ];then

		echo " |--- ENTRYPOINT_ARGS: "
		echo " |    |-- ARG1:		${1}"
		echo " |    |-- ARG2:		${2}"
		echo " |    |-- CASE:		$CASE"
		echo " |"

		echo " |--- ENTRYPOINT_CONFIG: "
		echo " |    |-- ENTRYPOINT_MODE:    		${ENTRYPOINT_MODE}"
		echo " |    |-- ENTRYPOINT_FALLBACK:		${ENTRYPOINT_FALLBACK}"
		echo " |    |-- ENTRYPOINT_ECHO:    		${ENTRYPOINT_ECHO}"
		echo " |"

		echo " |--- APP_CONFIG: "
		echo " |    |-- APP_PACKAGE_URI: ${APP_PACKAGE_URI}"

fi

if [ "$ENTRYPOINT_MODE" == "build_run" ];then

	APK_BUILD=""

	set +e
	GIT_EXECUTABLE=$(which git)
	GOLANG_EXECUTABLE=$(which go)
	GOX_EXECUTABLE=$(which gox)
	GLIDE_EXECUTABLE=$(which glide)
	GODEP_EXECUTABLE=$(which dep)
	NUT_EXECUTABLE=$(which dep)
	MYKE_EXECUTABLE=$(which myke)
	MKJWK_EXECUTABLE=$(which mkjwk)		
	BASH_EXECUTABLE=$(which bash)
	OPENSSL_EXECUTABLE=$(which openssl)

	set -e

	if [ "${GIT_EXECUTABLE}" == "" ]; then
		# --no-progress 
		apk update 
		apk --no-cache add git 
	fi

	if [ "${MKJWK_EXECUTABLE}" != "" ]; then
		mkdir -p ${APP_CERTIFICATES}
		cd ${APP_CERTIFICATES}
		mkjwk
		ls -l rsa_key 
		ls -l rsa_key.jwk
		cp -f rsa_key /dist/web/conf/${PROJECT_NAME}_rsa-key
		cp -f rsa_key /dist/cli/conf/${PROJECT_NAME}_rsa-key
		cp -f rsa_key.jwk /dist/cli/conf/${PROJECT_NAME}_rsa-key.jwk
		cp -f rsa_key.jwk /dist/web/conf/${PROJECT_NAME}_rsa-key.jwk
	fi

	if [ "${OPENSSL_EXECUTABLE}" != "" ]; then
		# rm -fR ${APP_CERTIFICATES}/${APP_SSL_SELFSIGNED_BASENAME}.*
		openssl req -out ${APP_CERTIFICATES}/${APP_SSL_SELFSIGNED_BASENAME}.csr -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -new -newkey rsa:2048 -nodes -keyout ${APP_CERTIFICATES}/${APP_SSL_SELFSIGNED_BASENAME}.key
		openssl req -x509 -sha256 -nodes -days 365 -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -newkey rsa:2048 -keyout ${APP_CERTIFICATES}/${APP_SSL_SELFSIGNED_BASENAME}.key -out ${APP_CERTIFICATES}/${APP_SSL_SELFSIGNED_BASENAME}.crt
		cp -Rf ${APP_SSL_SELFSIGNED_BASENAME}.* /dist/web/conf/
		cp -Rf ${APP_SSL_SELFSIGNED_BASENAME}.* /dist/cli/conf/
	fi

	if [ "$ENTRYPOINT_ECHO" == true ];then

		echo " |    |-- APP_GIT_COMMIT:			${APP_GIT_COMMIT}"
		echo " |    |-- APP_GIT_DIRTY: 			${APP_GIT_DIRTY}"
		echo " |"

		echo " |--- CONTAINER CONPONENTS: "
		echo " |    |"
		echo " |    |__VCS:"
		echo " |    |  |"
		echo " |    |  |-- GIT_EXECUTABLE:		${GIT_EXECUTABLE}"
		echo " |    |"
		echo " |    |__LANGUAGES:"
		echo " |       |"
		echo " |       |__ GOLANG:"
		echo " |         |"
		echo " |         |-- GOLANG_EXECUTABLE:		${GOLANG_EXECUTABLE}"
		echo " |         |-- GOX_EXECUTABLE:   		${GOX_EXECUTABLE}"
		echo " |         |-- GLIDE_EXECUTABLE: 		${GLIDE_EXECUTABLE}"
		echo " |         |-- GODEP_EXECUTABLE: 		${GODEP_EXECUTABLE}"
		echo " |         |-- NUT_EXECUTABLE:   		${NUT_EXECUTABLE}"
		echo " |         |-- MYKE_EXECUTABLE:  		${MYKE_EXECUTABLE}"
		echo " |         |-- MKJWK_EXECUTABLE: 		${MKJWK_EXECUTABLE}"
		echo " |"
	fi

fi

case "$CASE" in
	'xc')

		if [ "${GOLANG_EXECUTABLE}" == "" ]; then
			APK_BUILD="curl git mercurial bzr gcc musl-dev go g++ make"
			apk update 
			apk --no-cache --no-progress --virtual BUILD_DEPS add ${APK_BUILD}
		fi

		if [ "${GOX_EXECUTABLE}" == "" ]; then
			go get -v github.com/mitchellh/gox
			GOX_EXECUTABLE=$(which gox)
		fi

		if [ "${GLIDE_EXECUTABLE}" == "" ]; then
			go get -v github.com/Masterminds/glide
		fi

		if [ "${GODEP_EXECUTABLE}" == "" ]; then
			go get -u -v github.com/golang/dep/...
		fi

		cd ${PROJECT_SOURCE_PATH}

		APP_GIT_COMMIT=$(git rev-parse HEAD)
		APP_GIT_DIRTY=$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)

		gox -os="linux darwin" -arch="amd64" -ldflags "-X main.GitCommit=${APP_GIT_COMMIT}${APP_GIT_DIRTY}" -output /dist/{{.Dir}}/xc/{{.OS}}/${PROJECT_NAME}-{{.OS}}-{{.Arch}}-{{.Dir}} $(glide novendor)

		if [ -f "${APP_CLI}" ];then
			mkdir -p /dist/cli
			cp ${APP_CLI} /dist/cli/${PROJECT_NAME}_cli
		fi

		if [ -f "${APP_WEB}" ];then
			mkdir -p /dist/web
			cp ${APP_WEB} /dist/web/${PROJECT_NAME}_web
		fi

		if [ "$ENTRYPOINT_MODE" == "build_run" ];then	
		  if [ -f "/dist/${PROJECT_NAME}-linux-amd64-${2:-cli}" ];then
			  exec go /dist/${PROJECT_NAME}-linux-amd64-${@:2}
			elif [ "$ENTRYPOINT_FALLBACK" == true ]
			then
				if [ "${BASH_EXECUTABLE}" == "" ]; then
					apk update 
					apk --no-cache --no-progress add bash nano tree 
				fi
				exec /bin/bash ${@:2}
		  fi
		fi

	;;

	'generate-key')
		if [ "${MKJWK_EXECUTABLE}" == "" ]; then
		  go get -v -u github.com/dqminh/organizer/mkjwk
		fi
	  mkjwk ${@:2}
	  ls -l rsa_key 
	  ls -l rsa_key.jwk
	  mkdir -p /app/configuration/certs
	  cp -f rsa_key* /app/configuration/certs
	;;

	'cli')
		if [ "$ENTRYPOINT_MODE" == "build_run" ];then	
			GOOS=linux GOARCH=amd64 go build -o /dist/${PROJECT_NAME}-linux-amd64-cli cmd/cli/*.go
			exec go /dist/${APP_NAME}-linux-amd64-cli ${@:2}
		else
			exec go run cmd/web/main.go ${@:2}
		fi
	;;

	'web')
		if [ "$ENTRYPOINT_MODE" == "build_run" ];then	
		  GOOS=linux GOARCH=amd64 go build -o /dist/${PROJECT_NAME}-linux-amd64-web cmd/web/main.go
		  exec go /dist/${PROJECT_NAME}-linux-amd64-web ${@:2}
		else
		  exec go run cmd/web/main.go ${@:2}
		fi	

	;;

	'index')
		if [ "$ENTRYPOINT_MODE" == "build_run" ];then
			GOOS=linux GOARCH=amd64 go build -o /dist/${PROJECT_NAME}-linux-amd64-cli cmd/cli/*.go
			exec go /dist/${PROJECT_NAME}-linux-amd64-cli index create --index=${APP_DATA_DIR:-"/data"}/${PROJECT_NAME}.index --mapping=${APP_INDEX_MAPPING_FILE:-"./bleve/mapping.json"}
		else			
			#exec go run cmd/cli/*.go index create ${@:2}
			exec go run cmd/cli/*.go index create --index=${APP_DATA_DIR:-"/data"}/${PROJECT_NAME}.index --mapping=${APP_INDEX_MAPPING_FILE:-"./bleve/mapping.json"}
		fi
	;;

	'bash')
		if [ "${BASH_EXECUTABLE}" == "" ]; then
			apk --update --no-progress --no-cache add bash # --no-progress 
		fi
		exec /bin/bash ${@:2}

	;;

	'bashplus')
		if [ "${BASH_EXECUTABLE}" == "" ]; then
			apk --update --no-progress --no-cache add bash nano tree # --no-progress 
		fi
		exec /bin/bash ${@:2}

	;;

	'test')
		exec go test $(go list ./... | grep -v /vendor/)

	;;

	*)
		exec sh ${@:2}

	;;

esac

exit $?
