ARG VERSION=2.1.23
ARG GO_VERSION=1.27.3
ARG NODE_VERSION=24.19.0

FROM oci.badsysadm.local:80/src/net/zot:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG GO_VERSION
ARG NODE_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local
RUN update-alternatives --install /usr/bin/go go /usr/local/go/bin/go 100

RUN mkdir -p /opt/node \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
       | tar -xJ -C /opt/node --strip-components=1
RUN update-alternatives --install /usr/bin/node node /opt/node/bin/node 100 \
    && update-alternatives --install /usr/bin/npm npm /opt/node/bin/npm 100

COPY --from=src_image /src/ /src/

WORKDIR /src/zot
RUN GOTOOLCHAIN=local go mod vendor
WORKDIR /src/zui
RUN npm ci --no-audit --no-fund
