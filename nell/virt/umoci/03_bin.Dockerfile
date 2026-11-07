ARG VERSION=0.6.0

FROM oci.badsysadm.local:80/dep/virt/umoci:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off

WORKDIR /src/umoci
RUN go build -mod=vendor -buildvcs=false -trimpath \
    -ldflags "-s -w -X github.com/opencontainers/umoci.gitCommit=$(git rev-parse HEAD)" \
    -o /src/umoci/umoci ./cmd/umoci

RUN install -D -m 0755 umoci /src/target/usr/bin/umoci

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="umoci"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="OCI image unpacking and repacking"
COPY --from=build /src/target/ /target/
