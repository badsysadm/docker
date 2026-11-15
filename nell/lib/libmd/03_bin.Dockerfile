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

RUN make -j$(nproc) SUBDIRS="include src"
RUN make install DESTDIR=/src/target SUBDIRS="include src"
RUN find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libmd"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="BSD message digest static and shared libraries"
COPY --from=build /src/target/ /target/
