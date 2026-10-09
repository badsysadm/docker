ARG VERSION=7.2.0

FROM oci.badsysadm.local:80/dep/net/iproute2:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/iproute2

RUN mkdir -p /src/static-libs /src/pkgconfig && \
    cp \
        /usr/lib/x86_64-linux-gnu/libbpf.a \
        /usr/lib/x86_64-linux-gnu/libelf.a \
        /usr/lib/x86_64-linux-gnu/libmnl.a \
        /usr/lib/x86_64-linux-gnu/libcap.a \
        /usr/lib/x86_64-linux-gnu/libm.a \
        /usr/lib/x86_64-linux-gnu/libz.a \
        /usr/lib/x86_64-linux-gnu/libzstd.a \
        /src/static-libs/ && \
    for pc in libbpf libelf libmnl libcap zlib libzstd; do \
        cp "$(pkg-config --variable=pcfiledir ${pc})/${pc}.pc" /src/pkgconfig/; \
    done

RUN PKG_CONFIG_LIBDIR=/src/pkgconfig \
    PKG_CONFIG="pkg-config --static" \
    ./configure \
        --prefix=/usr \
        --libbpf_force=on

RUN make -j$(nproc) \
    SHARED_LIBS=n \
    LDFLAGS="-static-libgcc -L/src/static-libs -Wl,--as-needed"

RUN make install \
    DESTDIR=/src/target \
    SHARED_LIBS=n \
    LDFLAGS="-static-libgcc -L/src/static-libs -Wl,--as-needed"

RUN rm -rf \
        /src/target/usr/share/man \
        /src/target/usr/share/doc \
        /src/target/usr/share/bash-completion \
        /src/target/usr/include && \
    rm -f /src/target/sbin/routel

FROM scratch AS bundle
LABEL org.opencontainers.image.title="iproute2"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="networking and traffic control utilities"

COPY --from=build /src/target/ /target/
