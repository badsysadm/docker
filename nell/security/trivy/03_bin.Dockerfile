ARG VERSION=0.76.2

FROM oci.badsysadm.local:80/dep/security/trivy:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off

WORKDIR /src/trivy
RUN go build -mod=vendor -buildvcs=false -trimpath \
    -ldflags "-s -w -X github.com/aquasecurity/trivy/pkg/version/app.ver=${VERSION}" \
    -o /src/target/usr/bin/trivy ./cmd/trivy

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="trivy"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Vulnerability, misconfiguration and secret scanner"
COPY --from=build /src/target/ /target/
