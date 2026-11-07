ARG VERSION=0.42.0

FROM oci.badsysadm.local:80/dep/www/calino:${VERSION} AS build
ARG VERSION
ARG CALINO_SELF_HOSTED=true

COPY debian/patches /src/patches/
RUN git -C /src/calino apply /src/patches/_remove-product-metadata.patch
RUN git -C /src/calino apply /src/patches/_runtime-config.patch

WORKDIR /src/calino
RUN pnpm exec vite build

RUN mkdir -p /src/target/usr/share/calino
RUN cp -a /src/calino/dist/. /src/target/usr/share/calino/
COPY debian/config.json /src/target/usr/share/calino/config.json

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="calino"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Static CalDAV and CardDAV web client"
COPY --from=build /src/target/ /target/
