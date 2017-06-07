FROM alpine:3.6
MAINTAINER Rosco Pecoltran <rosco.pecoltran@msn.com>

ENV caddy_version=0.10.3

ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}
ARG APK_BUILD=${APK_BUILD:-"tar curl git openssl"}
ARG APK_RUNTIME=${APK_RUNTIME:-"ca-certificates"}
ARG APK_PACKAGES_INTERACTIVE=${APK_PACKAGES_INTERACTIVE:-"bash nano tree"}

LABEL caddy_version="$caddy_version" architecture="amd64"

ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

WORKDIR /code/app
COPY . /code/app

#         "https://caddyserver.com/download/linux/amd64?plugins=http.cgi,http.cors,http.expires,http.filemanager,http.git,http.ipfilter,http.realip,tls.dns.cloudflare,tls.dns.digitalocean,tls.dns.dnspod,tls.dns.dyn,tls.dns.googlecloud,tls.dns.linode,tls.dns.namecheap,tls.dns.ovh,tls.dns.route53,tls.dns.vultr" \
RUN chmod +x /usr/local/sbin/gosu \
	&& apk --no-cache --no-progress add ${APK_RUNTIME} ${APK_PACKAGES_INTERACTIVE} \
	&& apk --no-cache add --virtual devs ${APK_BUILD} && \
	adduser -D app -h /code/app -s /bin/sh && \
	curl --silent --show-error --fail --location \
        --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
        "https://caddyserver.com/download/linux/amd64?plugins=http.authz,http.cors,http.expires,http.git,http.ipfilter,http.minify,http.ratelimit,http.realip,http.upload,net,tls.dns.gandi,tls.dns.googlecloud,tls.dns.linode,tls.dns.ovh,tls.dns.route53" \
        | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && mv /usr/bin/caddy /usr/bin/caddy \
    && chmod 0755 /usr/bin/caddy \
	&& apk --no-cache --no-progress del devs \
	&& mv /code/app/Caddyfile /etc/Caddyfile \
	&& mv -f /code/app/index.html /code/index.html
	# ${APK_PACKAGES_INTERACTIVE}

EXPOSE 8080 2015

CMD ["/usr/bin/caddy", "-conf", "/etc/Caddyfile"]
# docker run -d -p "2015:2015" -w /data -v /path/to/your/website:/data papernet-front:dist-latest
# /usr/bin/caddy -conf /etc/Caddyfile