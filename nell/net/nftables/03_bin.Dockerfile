ARG VERSION=1.1.7

FROM oci.badsysadm.local:80/dep/net/nftables:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION
ARG SOURCE_DATE_EPOCH=0

WORKDIR /src/nftables

RUN export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH}" && \
    export PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig" && \
    export LDFLAGS="-static-libgcc" && \
    ./configure \
        --prefix=/usr \
        --sbindir=/usr/sbin \
        --sysconfdir=/etc \
        --disable-debug \
        --disable-man-doc \
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

RUN gcc -static-libgcc \
        -o /src/target/usr/sbin/nft \
        src/main.o \
        src/cli.o \
        -Wl,-Bstatic,--start-group \
        src/.libs/libnftables.a \
        $(pkg-config --static --libs libnftnl libmnl jansson libedit) \
        -Wl,--end-group,-Bdynamic

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="nftables"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="nftables static dependencies bundle"

COPY --from=build /src/target/ /target/
