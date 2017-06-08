FROM alpine:3.6
MAINTAINER Rosco Pecoltran <rosco_pecoltran@msn.com>

# Build args (no need to keep them as `env` variables)
ARG GOSU_VERSION=${GOSU_VERSION:-1.10}

# Install Gosu to /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

# Install runtime dependencies & create runtime user
RUN chmod +x /usr/local/sbin/gosu \
    apk --update upgrade \
    && apk --no-cache --no-progress add ca-certificates \
    && adduser -D app -h /data -s /bin/sh \
    && rm -rf /var/cache/apk/*

# Copy certificates and generated binary
COPY {{.APP_BINARY_NAME}} /usr/local/bin/
COPY ./docker-entrypoint.sh /

# NSSwitch configuration file (if web binary only)
COPY ./nsswitch.conf /etc/nsswitch.conf

# Container configuration
VOLUME ["/data"]
EXPOSE 1705
ENTRYPOINT ["/usr/local/sbin/gosu"]
CMD ["app", "/app/docker-entrypoint.sh"]

# ENTRYPOINT ["/app/docker-entrypoint.sh"]
# CMD ["--help"]

# Metadata
LABEL org.label-schema.vendor="{{.APP_VENDOR}}" \
      org.label-schema.url="{{.APP_WEBSITE}}" \
      org.label-schema.name="{{.APP_NAME}}" \
      org.label-schema.description="{{.APP_DESCRIPTION}}" \    
      org.label-schema.version="$VERSION" \
      org.label-schema.docker.schema-version="1.0"