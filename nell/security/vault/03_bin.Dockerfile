ARG VERSION=2.2.1

FROM oci.badsysadm.local:80/dep/security/vault:${VERSION} AS dep_image

# Build Ember assets using the Node.js and pnpm versions declared by upstream.
FROM node:24.19.0-bookworm AS ui_build
COPY --from=dep_image /src/vault/ /src/vault/
WORKDIR /src/vault/ui
RUN npm install --global pnpm@10.22.0
RUN pnpm install --frozen-lockfile
RUN pnpm run build
RUN test -s /src/vault/http/web_ui/index.html

FROM dep_image AS build
ARG VERSION
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOWORK=off
WORKDIR /src/vault

COPY --from=ui_build /src/vault/http/web_ui/ /src/vault/http/web_ui/

# The ui build tag embeds the production Ember assets into the server binary.
RUN mkdir -p /src/target/usr/bin \
    && go build -trimpath -buildvcs=false \
       -tags "vault ui" \
       -ldflags="-buildid=" \
       -o /src/target/usr/bin/vault ./command/server/cmd
RUN test -s /src/target/usr/bin/vault \
    && test -s /src/vault/http/web_ui/index.html

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="vault"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="HashiCorp Vault server with embedded Web UI"
COPY --from=build /src/target/ /target/
