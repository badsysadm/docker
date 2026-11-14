ARG VERSION=1.3.0

FROM oci.badsysadm.local:80/dep/lib/libmd:${VERSION} AS build
ARG VERSION

WORKDIR /src/libmd

RUN ./autogen
RUN CFLAGS="-O2 -fPIC" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-static \
    --enable-shared

RUN make -C src -j$(nproc)
RUN make -C src install DESTDIR=/src/target
RUN make -C include install DESTDIR=/src/target
RUN find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libmd"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="BSD message digest static and shared libraries"
COPY --from=build /src/target/ /target/
