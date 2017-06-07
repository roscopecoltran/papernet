FROM scratch
# FROM tianon/true
MAINTAINER Rosco Pecoltran <rosco_pecoltran@msn.com>
COPY ./papernet-cli /app/papernet-cli
ENV PATH=/app:$PATH
ENTRYPOINT ["/app/papernet-cli"]
# CMD ["index", "create", "--index=./data/papernet.index", "--mapping=./data/mapping.json"]
