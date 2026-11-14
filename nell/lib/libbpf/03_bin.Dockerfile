ARG VERSION=1.8.0

FROM oci.badsysadm.local:80/dep/lib/libbpf:${VERSION} AS build
ARG VERSION

WORKDIR /src/libbpf

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    make -j$(nproc) -C src \
    PREFIX=/usr \
    LIBDIR=/usr/lib \
    PKG_CONFIG=/usr/local/bin/nell-libbpf-pkg-config \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-L/usr/local/lib -static-libgcc" \
    all

RUN make -C src \
    PREFIX=/usr \
    LIBDIR=/usr/lib \
    DESTDIR=/src/target \
    install

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libbpf"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux BPF userspace library"
COPY --from=build /src/target/ /target/
