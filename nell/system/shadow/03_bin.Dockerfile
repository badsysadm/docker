ARG VERSION=4.20.3

FROM oci.badsysadm.local:80/dep/system/shadow:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/shadow

RUN mkdir -p /src/static-libs && \
    cp \
        /usr/lib/x86_64-linux-gnu/libaudit.a \
        /usr/lib/x86_64-linux-gnu/libcap-ng.a \
        /usr/lib/x86_64-linux-gnu/libacl.a \
        /usr/lib/x86_64-linux-gnu/libcrypt.a \
        /src/static-libs/

COPY debian/patches /src/patches/

RUN patch -p1 < /src/patches/static-audit-deps.patch

RUN find . -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

RUN autoreconf -fi

RUN LDFLAGS="-L/src/static-libs -Wl,--as-needed" ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-logind \
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

RUN sed -i \
    -e 's|^LIBAUDIT =.*|LIBAUDIT = -Wl,-Bstatic -laudit -lcap-ng -Wl,-Bdynamic|' \
    -e 's|^LIBACL =.*|LIBACL = -Wl,-Bstatic -lacl -Wl,-Bdynamic|' \
    -e 's|^LIBCRYPT =.*|LIBCRYPT = -Wl,-Bstatic -lcrypt -Wl,-Bdynamic|' \
    src/Makefile libsubid/Makefile

RUN make -j$(nproc) -C lib
RUN make -j$(nproc) -C libsubid

RUN sed -i \
    's|$(top_builddir)/libsubid/libsubid.la|$(top_builddir)/libsubid/.libs/libsubid.a|g' \
    src/Makefile

RUN make -j$(nproc) \
    LDFLAGS="-L/src/static-libs -Wl,--as-needed"
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
