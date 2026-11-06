ARG VERSION=3.7.3

FROM oci.badsysadm.local:80/dep/net/etcd:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off
ENV GO_BUILD_FLAGS="-mod=vendor -buildvcs=false"

WORKDIR /src/etcd
RUN ./scripts/build.sh

RUN mkdir -p /src/target/usr/bin \
    && cp bin/etcd bin/etcdctl bin/etcdutl /src/target/usr/bin/

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="etcd"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Distributed key-value store with administrative tools"
COPY --from=build /src/target/ /target/
