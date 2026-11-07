ARG VERSION=2026-10-26T00-00-00Z

FROM oci.badsysadm.local:80/dep/utils/siloctl:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off

WORKDIR /src/siloctl
RUN go build -mod=vendor -buildvcs=false -trimpath -tags kqueue \
    -ldflags "-s -w -X github.com/minio/mc/cmd.Version=${VERSION} -X github.com/minio/mc/cmd.CopyrightYear=2026 -X github.com/minio/mc/cmd.ReleaseTag=RELEASE.${VERSION} -X github.com/minio/mc/cmd.CommitID=$(git rev-parse HEAD) -X github.com/minio/mc/cmd.ShortCommitID=$(git rev-parse --short=12 HEAD)" \
    -o /src/siloctl/siloctl .

RUN install -D -m 0755 /src/siloctl/siloctl /src/target/usr/bin/siloctl

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="siloctl"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="S3-compatible object storage client (Silo mcli fork)"
COPY --from=build /src/target/ /target/
