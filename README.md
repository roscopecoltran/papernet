[![Build Status](https://travis-ci.org/bobinette/papernet.svg?branch=master)](https://travis-ci.org/bobinette/papernet)

# Papernet

Papernet is a very simple tool to keep track of the papers you read.

# Setup

## Docker

### Docker

Install pre-requisites:
```bash
brew install docker
```

Build Papernet Web-API & Front-end
```bash
make papernet.docker.all    	
make papernet.docker.dev.all	
make papernet.docker.dist.all
```

### Docker-Compose

Install pre-requisites:
```bash
brew install docker-compose
```

Build Papernet Web-API & Front-end
```bash
make papernet.docker.compose.all     	# will build dev containers (alpine 3.6), build dist files and wrap them into small containers (scratch or alpine 3.6)
make papernet.docker.compose.dev.all 	# will build dev containers (alpine 3.6), shared locally generated output
make papernet.docker.compose.dist.all	# build dist files from dev containers, wrap them into small containers (scratch or alpine 3.6)
```

## Go
Usual go installation (1.7.5)

I use the gvm, but you can install golang any way you prefer
```bash
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
gvm install go1.7.5 --binary
```

then add the following to your bashrc (or the equivalent for your terminal)
```bash
source $HOME/.gvm/scripts/gvm
gvm use go1.7.5
export GOPATH=/path/to/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

## Dependencies
The dependencies are handled with `godep`:
```bash
go get -u github.com/tools/godep
dep ensure
```

## Auth

### Key file

You need to generate your shared secret for the authentication. You can use this site to do so: https://mkjwk.org/, with the following settings:
![image](https://cloud.githubusercontent.com/assets/9349295/26157368/53806e4e-3b19-11e7-816e-6f9f8f774a5b.png)
You decide what you want to use as key ID

### Google oauth

If you want to use Google to handle the auth, you need credentials for the project. Follow the instructions here: https://developers.google.com/identity/protocols/OAuth2, to create those credentials.

If you do not want to use google for oauth, you can simply set `enabled=false` in the configuration file and use the simple email/password login system. It does not include email confirmation or password reset, but it will avoid you having to register Papernet on Google.

## Web server
To start the web server, you have to create the `data` folder, and setup the index:
```bash
mkdir data
go run cmd/cli/*.go index create --index=data/papernet.index --mapping=bleve/mapping.json
```

Now that everything is ready, you can start the server:
```bash
go run cmd/web/main.go
```

## Front-end
This repository contains the backend of the Papernet project, for the front-end check out https://github.com/bobinette/papernet-front

You can also pull it using the git subtree command into the ./contrib/webui folder:
```bash
make papernet.webui.pull  	# add or pull subtree if already exists locally
make papernet.webui.clean 	# remove all dist files generated into the ./dist/front/content folder.
make papernet.webui.remove	# remove all Papernet Front files from your local repository clone
```

## Ops
This repository contains the OPS helpers for the Papernet project, for the OPS helpers check out https://github.com/bobinette/papernet-ops

You can also pull it using the git subtree command into the ./contrib/ops folder:
```bash
make papernet.ops.pull    	# add or pull subtree if already exists locally
make papernet.webui.remove	# remove all Papernet OPS files from your local repository clone
```


