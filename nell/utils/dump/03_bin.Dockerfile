ARG VERSION=0.4b56

FROM oci.badsysadm.local:80/dep/utils/dump:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/dump

RUN mkdir -p /src/static-libs && \
    cp \
        /usr/lib/x86_64-linux-gnu/libext2fs.a \
        /usr/lib/x86_64-linux-gnu/libcom_err.a \
        /usr/lib/x86_64-linux-gnu/libe2p.a \
        /usr/lib/x86_64-linux-gnu/libblkid.a \
        /usr/lib/x86_64-linux-gnu/libuuid.a \
        /usr/lib/x86_64-linux-gnu/libreadline.a \
        /usr/lib/x86_64-linux-gnu/libtinfo.a \
        /usr/lib/x86_64-linux-gnu/libz.a \
        /usr/lib/x86_64-linux-gnu/libbz2.a \
        /usr/lib/x86_64-linux-gnu/liblzo2.a \
        /usr/lib/x86_64-linux-gnu/libselinux.a \
        /usr/lib/x86_64-linux-gnu/libsepol.a \
        /usr/lib/x86_64-linux-gnu/libpcre2-8.a \
        /src/static-libs/

RUN PKG_CONFIG="pkg-config --static" \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --sbindir=/sbin \
        --disable-shared \
        --enable-static \
        --enable-rmt \
        --disable-ermt \
        --enable-readline \
        --enable-qfa \
        --enable-selinux \
        --enable-blkid \
        --enable-uuid \
        --enable-zlib \
        --enable-bzip2 \
        --enable-lzo \
        --disable-sqlite \
        --disable-ssl

RUN make -j$(nproc) \
    LDFLAGS="-L/src/static-libs -Wl,--as-needed"

RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share \
    /src/target/share

FROM scratch AS bundle
LABEL org.opencontainers.image.title="dump"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="backup and restore for ext2/3/4 filesystems"

COPY --from=build /src/target/ /target/
