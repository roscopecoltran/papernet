FROM alpine:3.6
MAINTAINER Rosco Pecoltran <rosco.pecoltran@msn.com>

ENV GOPATH /go
ENV CADDY_TAG v0.10.3

RUN apk add --no-cache --update musl \
    && apk add --no-cache -t build-tools build-base go mercurial git \
    && mkdir /go \
    && cd /go \
    && go get -tags=$CADDY_TAG github.com/mholt/caddy/... \
    && mv $GOPATH/bin/caddy /bin \
    && mkdir /caddy \
    && apk del --purge build-tools \
    && rm -rf /go /var/cache/apk/*

EXPOSE     2015
VOLUME     [ "/caddy" ]
WORKDIR    "/caddy"
ENTRYPOINT [ "/bin/caddy" ]
CMD        [ "-conf='/caddy/Caddyfile'" ]