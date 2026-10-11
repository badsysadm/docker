ARG VERSION=4.20.3

FROM oci.badsysadm.local:80/dep/system/shadow:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/shadow

RUN find . -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --with-libpam=yes \
    --with-audit=yes \
    --with-acl=yes \
    --with-selinux=no \
    --with-btrfs=no \
    --with-tcb=no \
    --with-skey=no \
    --with-libbsd=no \
    --without-bcrypt \
    --without-yescrypt \
    --enable-static \
    --enable-shared \
    --disable-man

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/doc \
    /src/target/usr/share/info \
    /src/target/usr/share/locale && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
LABEL org.opencontainers.image.title="shadow"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Shadow password and account management utilities"

COPY --from=build /src/target/ /target/
