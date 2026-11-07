ARG VERSION=0.42.0
ARG NODE_VERSION=24.19.0
ARG PNPM_VERSION=10.30.3

FROM oci.badsysadm.local:80/src/www/calino:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG NODE_VERSION
ARG PNPM_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN mkdir -p /opt/node \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
       | tar -xJ -C /opt/node --strip-components=1
RUN update-alternatives --install /usr/bin/node node /opt/node/bin/node 100
RUN update-alternatives --install /usr/bin/npm npm /opt/node/bin/npm 100
RUN npm install --global --prefix /opt/pnpm "pnpm@${PNPM_VERSION}"
RUN update-alternatives --install /usr/bin/pnpm pnpm /opt/pnpm/bin/pnpm 100

COPY --from=src_image /src/ /src/

WORKDIR /src/calino
RUN pnpm install --frozen-lockfile --package-import-method=hardlink
