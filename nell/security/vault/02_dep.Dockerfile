ARG VERSION=2.2.1
ARG GO_VERSION=1.27.3
ARG NODE_VERSION=24.19.0
ARG PNPM_VERSION=10.22.0

FROM oci.badsysadm.local:80/src/security/vault:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG GO_VERSION
ARG NODE_VERSION
ARG PNPM_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

# Install upstream toolchains and register their executables.
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local
RUN update-alternatives --install /usr/bin/go go /usr/local/go/bin/go 100

RUN mkdir -p /opt/node \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
       | tar -xJ -C /opt/node --strip-components=1
RUN update-alternatives --install /usr/bin/node node /opt/node/bin/node 100 \
    && update-alternatives --install /usr/bin/npm npm /opt/node/bin/npm 100
RUN npm install --global --prefix /opt/pnpm "pnpm@${PNPM_VERSION}" \
    && update-alternatives --install /usr/bin/pnpm pnpm /opt/pnpm/bin/pnpm 100

COPY --from=src_image /src/ /src/

# Vendor all modules in the upstream Go workspace before the binary build.
WORKDIR /src/vault
RUN GOTOOLCHAIN=local go work vendor

# Resolve UI dependencies while networking is available in the dep stage.
WORKDIR /src/vault/ui
RUN pnpm install --frozen-lockfile --package-import-method=hardlink
