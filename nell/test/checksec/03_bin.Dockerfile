ARG VERSION=3.2.0

FROM oci.badsysadm.local:80/dep/test/checksec:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off

WORKDIR /src/checksec

RUN mkdir -p /src/target/usr/bin
RUN go build -mod=vendor -buildvcs=false -trimpath \
    -ldflags "-s -w -buildid= -X main.version=${VERSION} -X main.commit=none -X main.date=unknown" \
    -o /src/target/usr/bin/checksec .

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="checksec"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Executable hardening and security property checker"
COPY --from=build /src/target/ /target/
