ARG VERSION=2.42.2

FROM oci.badsysadm.local:80/dep/utils/util-linux:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/util-linux

COPY debian/patches /src/patches/
RUN patch -p1 < /src/patches/_build.patch
RUN autoreconf -fi
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc -L/usr/local/lib -Wl,--gc-sections" \
    --prefix=/usr \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --libdir=/usr/lib \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-nls \
    --without-btrfs \
    --disable-asciidoc \
    --disable-pylibmount \
    --enable-liblastlog2 \
    --enable-pam-lastlog2 \
    --without-systemd \
    --without-selinux \
    --without-cryptsetup \
    --enable-static-programs=blkid,fdisk,losetup,mount,nsenter,partx,sfdisk,umount,unshare

RUN make -j$(nproc) AM_LDFLAGS="-static-libtool-libs"
RUN make install DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="util-linux"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="util-linux binaries"
COPY --from=build /src/target/ /target/
