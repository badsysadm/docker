ARG VERSION=2.1.23

FROM oci.badsysadm.local:80/dep/net/zot:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOEXPERIMENT=jsonv2
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off
ENV npm_config_offline=true
ENV GO_TAGS=sync,search,scrub,metrics,lint,ui,mgmt,profile,userprefs,imagetrust,events

WORKDIR /src/zui
RUN npm run build
RUN cp -a /src/zui/build /src/zot/pkg/extensions/build

WORKDIR /src/zot
RUN go build -mod=vendor -buildvcs=false -trimpath -buildmode=pie \
    -tags "${GO_TAGS}" \
    -ldflags "-s -w -X zotregistry.dev/zot/v2/pkg/buildinfo.ReleaseTag=v${VERSION} -X zotregistry.dev/zot/v2/pkg/buildinfo.Commit=$(git rev-parse --short HEAD) -X zotregistry.dev/zot/v2/pkg/buildinfo.BinaryType=extended -X zotregistry.dev/zot/v2/pkg/buildinfo.GoVersion=$(go version | awk '{print $3}')" \
    -o /src/zot/zot ./cmd/zot

RUN go build -mod=vendor -buildvcs=false -trimpath -buildmode=pie \
    -tags "${GO_TAGS}" \
    -ldflags "-s -w -X zotregistry.dev/zot/v2/pkg/buildinfo.Commit=$(git rev-parse --short HEAD) -X zotregistry.dev/zot/v2/pkg/buildinfo.BinaryType=extended -X zotregistry.dev/zot/v2/pkg/buildinfo.GoVersion=$(go version | awk '{print $3}')" \
    -o /src/zot/zli ./cmd/zli

RUN install -D -m 0755 -t /src/target/usr/bin \
    zot zli

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="zot"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="OCI image registry and client"
COPY --from=build /src/target/ /target/
