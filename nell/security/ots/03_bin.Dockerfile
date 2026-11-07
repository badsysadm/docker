ARG VERSION=1.23.1

FROM oci.badsysadm.local:80/dep/security/ots:${VERSION} AS build
ARG VERSION

ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off
ENV npm_config_offline=true
ENV SOURCE_DATE_EPOCH=1 NODE_ENV=production

WORKDIR /src/ots
RUN pnpm redocly --disableGoogleFont true \
    -o frontend/api.html build-docs docs/openapi.yaml
RUN pnpm node ci/build.mjs
RUN go build -mod=vendor -buildvcs=false -trimpath \
    -ldflags "-s -w -buildid= -X main.version=v${VERSION}" \
    -o /src/ots/ots .

RUN install -D -m 0755 ots /src/target/usr/bin/ots

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="ots"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="One-time secret sharing server with embedded Web UI"
COPY --from=build /src/target/ /target/
