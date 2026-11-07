ARG VERSION=0.42.0

FROM oci.badsysadm.local:80/src/www/calino:${VERSION} AS src_image
FROM docker.io/library/node:25-bookworm AS node_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=node_image /usr/local/ /usr/local/

RUN npm install -g corepack@latest --force
RUN corepack enable
RUN corepack prepare pnpm@10.30.3 --activate

COPY --from=src_image /src/ /src/

WORKDIR /src/calino
RUN pnpm install --frozen-lockfile --package-import-method=hardlink
