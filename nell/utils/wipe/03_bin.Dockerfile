ARG VERSION=0.24

FROM oci.badsysadm.local:80/dep/utils/wipe:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/wipe

RUN make -j$(nproc) linux LDFLAGS="-static"

RUN install -D -m 0755 wipe /src/target/usr/bin/wipe

FROM scratch AS bundle
LABEL org.opencontainers.image.title="wipe"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="secure file deletion utility"

COPY --from=build /src/target/ /target/
