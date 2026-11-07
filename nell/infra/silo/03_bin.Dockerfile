ARG VERSION=2026-10-26T00-00-00Z

FROM oci.badsysadm.local:80/dep/infra/silo:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off

WORKDIR /src/silo
RUN go build -mod=vendor -buildvcs=false -trimpath -tags kqueue \
    -ldflags "-s -w -X github.com/minio/minio/cmd.Version=$(echo ${VERSION} | sed 's/T00-00-00Z/T00:00:00Z/') -X github.com/minio/minio/cmd.CopyrightYear=2026 -X github.com/minio/minio/cmd.ReleaseTag=RELEASE.${VERSION} -X github.com/minio/minio/cmd.CommitID=$(git rev-parse HEAD) -X github.com/minio/minio/cmd.ShortCommitID=$(git rev-parse --short=12 HEAD)" \
    -o /src/silo/silo .

RUN install -D -m 0755 /src/silo/silo /src/target/usr/sbin/silo

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="silo"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="S3-compatible object storage server (MinIO fork)"
COPY --from=build /src/target/ /target/
