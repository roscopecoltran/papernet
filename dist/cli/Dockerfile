FROM scratch
# FROM tianon/true
MAINTAINER Rosco Pecoltran <rosco_pecoltran@msn.com>
COPY papernet_cli_linux_amd64 /app/papernet_cli_linux_amd64
ENV PATH=/app:$PATH
ENTRYPOINT ["/app/papernet_cli_linux_amd64"]
# CMD ["index", "create", "--index=./data/papernet.index", "--mapping=./data/mapping.json"]
