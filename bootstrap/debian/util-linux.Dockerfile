FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG UTIL_LINUX_VERSION=2.42.2
ARG UTIL_LINUX_MAJOR=v2.42
ARG FORCE_UNSAFE_CONFIGURE=1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates autoconf automake libtool autopoint wget bison flex texinfo \
    libsqlite3-dev libjson-c-dev libdevmapper-dev libpam0g-dev \
    libaudit-dev libcap-ng-dev

RUN mkdir -p /src/util-linux /src/target && \
    wget -qO- https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/${UTIL_LINUX_MAJOR}/util-linux-${UTIL_LINUX_VERSION}.tar.xz | tar -xJf - -C /src/util-linux --strip-components=1

WORKDIR /src/util-linux

RUN ./configure \
    --prefix=/usr \
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

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="util-linux"
LABEL org.opencontainers.image.version="2.42.2"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="util-linux binaries"
COPY --from=build /src/target/ /
