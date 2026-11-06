ARG VERSION=1.249

FROM oci.badsysadm.local:80/dep/usr/console-setup:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/console-setup

RUN make -j$(nproc) build-linux
RUN make prefix=/src/target/usr etcdir=/src/target/etc install-linux

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/doc \
    /src/target/usr/share/info \
    /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="console-setup"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux console keyboard layout and font configuration"
COPY --from=build /src/target/ /target/
