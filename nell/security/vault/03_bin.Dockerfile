ARG VERSION=2.2.1

FROM oci.badsysadm.local:80/dep/security/vault:${VERSION} AS build
ARG VERSION

# All toolchains and dependencies are supplied by the dep image.
ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOWORK=off
ENV GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off
ENV npm_config_offline=true

WORKDIR /src/vault/ui
RUN pnpm run build

WORKDIR /src/vault
RUN mkdir -p /src/target/usr/bin \
    && go build -mod=vendor -trimpath -buildvcs=false \
       -tags "vault ui" \
       -o /src/target/usr/bin/vault ./command/server/cmd

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="vault"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="HashiCorp Vault server with embedded Web UI"
COPY --from=build /src/target/ /target/
