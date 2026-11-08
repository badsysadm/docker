ARG VERSION=6.6

FROM oci.badsysadm.local:80/dep/lib/ncurses:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/ncurses

COPY debian/patches /src/patches/
RUN patch -p1 < /src/patches/_static-progs.patch

RUN cf_cv_ar_flags=-crD ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/usr/bin \
    --libdir=/usr/lib \
    --without-manpages \
    --without-tests \
    --with-normal \
    --with-shared \
    --without-debug \
    --enable-widec \
    --enable-pc-files \
    --with-pkg-config-libdir=/usr/lib/pkgconfig \
    --enable-ext-colors \
    --enable-ext-mouse

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="ncurses"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="ncurses libraries and terminal utilities"
COPY --from=build /src/target/ /target/
