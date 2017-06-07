#!/bin/sh
set -x
set -e

# Rosco Pecoltran - 2017
# This script builds the application from source for multiple platforms.

# Set temp environment vars
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
export BUILDPATH=${GOPATH}/src/${APP_PACKAGE_URI}
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

if [ "$GOLANG_PKG_MANAGER" == "glide" ];then
  export GLIDE_HOME=${GOPATH}/glide/home
  export GLIDE_TMP=${GOPATH}/glide/tmp
  mkdir -p ${GLIDE_HOME}
  mkdir -p ${GLIDE_TMP}

elif [ "$GOLANG_PKG_MANAGER" == "godep" ];then
  export CCACHE_DIR="${GOPATH}/godep/cache"
  mkdir -p ${CCACHE_DIR}
  #export HOME="${GOPATH}/godep/home"
  #mkdir -p ${HOME}

fi

# Install build deps
apk update
apk --no-cache --no-progress --virtual INTERACTIVE add ${ALPINE_PKG_INTERACTIVE}
apk --no-cache --no-progress --virtual RUNTIME add ${ALPINE_PKG_RUNTIME} 
apk --no-cache --no-progress --virtual BUILD add ${ALPINE_PKG_BUILD}

# Get the parent directory of where this script is.
SOURCE="$0"

while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done

# Get the git commit
CURRENT_DIR=$(pwd)


# If its dev mode, only build for ourself
if [ "${TF_DEV}x" != "x" ]; then
    XC_OS=${XC_OS:-$(go env GOOS)}
    XC_ARCH=${XC_ARCH:-$(go env GOARCH)}
fi

# Determine the arch/os combos we're building for
XC_ARCH=${XC_ARCH:-"386 amd64 arm"}
XC_OS=${XC_OS:-linux darwin windows freebsd openbsd}

# Install dependencies
echo "==> Getting dependencies..."
go get -v github.com/mitchellh/gox

if [ "$GOLANG_PKG_MANAGER" == "glide" ];then
  go get -v github.com/Masterminds/glide
#elif [ "$GOLANG_PKG_MANAGER" == "godep" ];then
else
  go get -u -v github.com/golang/dep/...
fi

# Init go environment to build papernet
mkdir -p $(dirname ${BUILDPATH})
ln -s /app ${BUILDPATH}
cd ${BUILDPATH}

if [ "$GOLANG_PKG_MANAGER" == "glide" ];then
  glide install --strip-vendor
  # nb. go test $(glide novendor)

else
#elif [ "$GOLANG_PKG_MANAGER" == "godep" ];then
  # bug. https://github.com/golang/dep/issues/372
  # dep init
  dep ensure
fi

# Delete the old dir
echo "==> Removing old directory..."
#rm -f /dist/cli/${APP_NAME}_*
#rm -f /dist/dist/${APP_NAME}_*

# Build!
echo "==> Building..."
set +e
#    -output "/dist/{{.OS}}_{{.Arch}}/${APP_NAME}-{{.Dir}}" \

if [ -d "$BUILDPATH/.git" ];then
  GIT_COMMIT=$(git rev-parse HEAD)
  GIT_DIRTY=$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)
  XC_LDFLAGS="-ldflags \"-X main.GitCommit ${GIT_COMMIT}${GIT_DIRTY}\""
else
  XC_LDFLAGS=""
fi

if [ "$GOLANG_PKG_MANAGER" == "glide" ];then
  XC_SOURCE=$(glide novendor)
else
  XC_SOURCE="./cmd/..."
fi

mkdir -p /dist

gox -os="linux darwin" -arch="amd64" -ldflags "-X main.GitCommit ${GIT_COMMIT}${GIT_DIRTY}" -output /dist/crossbuild/{{.OS}}/{{.Dir}}/${APP_NAME}-{{.OS}}-{{.Arch}}-{{.Dir}} $(glide novendor)

cp /dist/linux/cli/crossbuild/${APP_NAME}-linux-amd64-cli /bin/dist/cli/${APP_NAME}-linux-amd64-cli
cp /dist/linux/web/crossbuild/${APP_NAME}-linux-amd64-web /bin/dist/cli/${APP_NAME}-linux-amd64-web

# bug with os and arch parameters when passed as docker build arguments
# gox -os="${XC_OS}" -arch="${XC_ARCH}" ${XC_LDFLAGS} -output \"/dist/{{.Dir}}/${APP_NAME}_{{.Dir}}_{{.OS}}_{{.Arch}}\" ${XC_SOURCE}

set -e

# Make sure "papernet-papernet" is renamed properly
for PLATFORM in $(find /dist -mindepth 1 -maxdepth 1 -type d); do
  set +e
  mv ${PLATFORM}/${APP_NAME}-${APP_NAME}.exe ${PLATFORM}/${APP_NAME}.exe 2>/dev/null
  mv ${PLATFORM}/${APP_NAME}-${APP_NAME} ${PLATFORM}/${APP_NAME} 2>/dev/null
  set -e
done

# Move all the compiled things to the $GOPATH/bin
GOPATH=${GOPATH:-$(go env GOPATH)}
case $(uname) in
  CYGWIN*)
      GOPATH="$(cygpath $GOPATH)"
      ;;
esac
OLDIFS=$IFS

if [ "$APP_GENERATE_AUTH" == "mkjwk" ];then
  go get -v -u github.com/dqminh/organizer/mkjwk
  mkjwk
  ls -l rsa_key 
  ls -l rsa_key.jwk
  mkdir -p /app/certs
  cp -f rsa_key* /app/certs
fi

#IFS=: 
#MAIN_GOPATH=($GOPATH)
#IFS=$OLDIFS

# Copy our OS/Arch to the bin/ directory
# echo "==> Copying binaries for this platform..."
# DEV_PLATFORM="./dist/$(go env GOOS)_$(go env GOARCH)"
# for F in $(find ${DEV_PLATFORM} -mindepth 1 -maxdepth 1 -type f); do
  # cp -Rf ${F} /bin/
  # cp ${F} ${MAIN_GOPATH}/bin/
# done

# Done!
echo
echo "==> Results:"
ls -hl /dist/

# Cleanup GOPATH
# rm -r ${GOPATH}

# Remove stack of deps 'BUILD'
# apk --no-cache --no-progress del BUILD

# Remove build deps
# for STACK_NAME in ${ALPINE_PKG_DEL_STACKS[@]}; do
#   apk --no-cache --no-progress del ${STACK_NAME}
# done

