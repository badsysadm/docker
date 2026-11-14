ARG VERSION=1.8.0

FROM oci.badsysadm.local:80/dep/lib/libbpf:${VERSION} AS build
ARG VERSION

WORKDIR /src/libbpf

RUN make -j$(nproc) -C src \
    PREFIX=/usr \
    LIBDIR=/usr/lib \
    CFLAGS="-O2 -fPIC -I/usr/local/include -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc -Wl,-Bstatic -Wl,--start-group /usr/local/lib/libelf.a /usr/local/lib/libz.a /usr/local/lib/libzstd.a -Wl,--end-group -Wl,-Bdynamic" \
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
