FROM scratch
#FROM tianon/true
MAINTAINER Rosco Pecoltran <rosco_pecoltran@msn.com>
COPY ./papernet-web /app/papernet-web
EXPOSE 1705
ENV PATH=/app:$PATH
ENTRYPOINT ["/app/papernet-web"]
#ENTRYPOINT /papernet-web
