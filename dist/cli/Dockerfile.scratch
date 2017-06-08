FROM scratch
# FROM tianon/true
MAINTAINER Rosco Pecoltran <rosco_pecoltran@msn.com>
ADD ./conf /app/conf/
COPY ./papernet_cli /app/papernet_cli
ENV PATH=/app:$PATH
VOLUME ["/app/data"]
WORKDIR /app
ENTRYPOINT ["/app/papernet_cli"]
# CMD ["index", "create", "--index=./data/papernet.index", "--mapping=./data/mapping.json"]
