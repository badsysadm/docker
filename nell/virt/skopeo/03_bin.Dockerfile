ARG VERSION=1.24.1

FROM oci.badsysadm.local:80/dep/virt/skopeo:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off
ENV GO_TAGS=containers_image_openpgp,exclude_graphdriver_btrfs

WORKDIR /src/skopeo
RUN go build -mod=vendor -buildvcs=false -trimpath \
    -tags "${GO_TAGS}" \
    -ldflags "-s -w" \
    -o /src/skopeo/skopeo ./cmd/skopeo

RUN install -D -m 0755 skopeo /src/target/usr/bin/skopeo

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="skopeo"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Container image inspection and transfer"
COPY --from=build /src/target/ /target/
