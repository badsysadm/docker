ARG VERSION=1.5.7

FROM oci.badsysadm.local:80/dep/lib/zstd:${VERSION} AS build
ARG VERSION

WORKDIR /src/zstd

RUN make -j$(nproc) CFLAGS="-O2 -fPIC"

RUN make install \
    PREFIX=/usr \
    LIBDIR=/usr/lib/x86_64-linux-gnu \
    DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="zstd"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Zstandard compressor and compression library"
COPY --from=build /src/target/ /target/
