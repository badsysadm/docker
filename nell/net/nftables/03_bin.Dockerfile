ARG VERSION=1.1.7

FROM oci.badsysadm.local:80/dep/net/nftables:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/nftables

RUN export PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig" && \
    export PKG_CONFIG="pkg-config --static" && \
    export LDFLAGS="-static-libgcc -Wl,-Bstatic" && \
    export LIBS="$(pkg-config --static --libs libedit) -Wl,-Bdynamic" && \
    ./configure \
        --prefix=/usr \
        --sbindir=/usr/sbin \
        --sysconfdir=/etc \
        --disable-debug \
        --disable-man-doc \
        --disable-fuzzer \
        --disable-distcheck \
        --disable-profiling \
        --enable-extended-parser-errors \
        --with-mini-gmp \
        --with-cli=editline \
        --without-xtables \
        --with-json \
        --with-unitdir=/usr/lib/systemd/system \
        --enable-static \
        --disable-shared

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info

RUN ! readelf -d /src/target/usr/sbin/nft | grep NEEDED | grep -v 'libc.so.6'

FROM scratch AS bundle
LABEL org.opencontainers.image.title="nftables"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="nftables static dependencies bundle"

COPY --from=build /src/target/ /target/
