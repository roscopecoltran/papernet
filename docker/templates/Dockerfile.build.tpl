FROM [*BASE_IMAGE_NAME*]:%%BASE_IMAGE_TAG%%
MAINTAINER [*AUTHOR_NAME*] <[*AUTHOR_EMAIL*]>

# ENV DOCKER_COMMAND="[*COMMAND*]"

# Metadata
LABEL org.label-schema.vendor="%%APP_VENDOR%%" \
	  org.label-schema.vcs-url="https://github.com/%%DOCKER_PROJECT%%/docker-%%DOCKER_NAME%%" \
      org.label-schema.url="[*PROJECT_URL*]" \
      org.label-schema.name="%%DOCKER_PROJECT%%/%%DOCKER_NAME%%" \
      org.label-schema.description="%%DOCKER_DESCRIPTION%%" \    
      org.label-schema.version="%%APP_VERSION%%" \
      org.label-schema.build-date="%%REFRESHED_AT%%" \
      org.label-schema.docker.schema-version="1.0"

COPY ./certs/ca-certificates.crt /etc/ssl/certs/
COPY [*COMMAND_EXECUTABLE*] /app/

EXPOSE [*EXPOSE_PORTS*]

ENTRYPOINT ["[*COMMAND*]"]

CMD ["[*COMMAND*]"]