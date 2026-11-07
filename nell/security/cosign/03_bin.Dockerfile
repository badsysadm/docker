ARG VERSION=3.1.4

FROM oci.badsysadm.local:80/dep/security/cosign:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off

WORKDIR /src/cosign
RUN mkdir -p /src/target/usr/bin && \
    go build -mod=vendor -buildvcs=false -trimpath \
    -ldflags "-s -w -buildid= -X sigs.k8s.io/release-utils/version.gitVersion=v${VERSION} -X sigs.k8s.io/release-utils/version.gitTreeState=clean" \
    -o /src/target/usr/bin/cosign ./cmd/cosign

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="cosign"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Sigstore Cosign artifact signing and verification"
COPY --from=build /src/target/ /target/
