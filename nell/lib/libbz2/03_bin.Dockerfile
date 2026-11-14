ARG VERSION=1.0.8

FROM oci.badsysadm.local:80/dep/lib/libbz2:${VERSION} AS build
ARG VERSION

WORKDIR /src/bzip2

COPY debian/patches /src/patches/
RUN patch -p1 -i /src/patches/_build.patch

RUN make -j$(nproc) libbz2.a libbz2.so CFLAGS="-O2 -fPIC -D_FILE_OFFSET_BITS=64"
RUN make install PREFIX=/src/target/usr CFLAGS="-O2 -fPIC -D_FILE_OFFSET_BITS=64"
RUN rm -rf /src/target/usr/bin /src/target/usr/man

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libbz2"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Bzip2 static and shared compression libraries"
COPY --from=build /src/target/ /target/
