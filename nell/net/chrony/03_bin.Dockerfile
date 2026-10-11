ARG VERSION=4.9

FROM oci.badsysadm.local:80/dep/net/chrony:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/chrony

RUN PKG_CONFIG="pkg-config --static" ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-user=_chrony \
    --without-nss \
    --disable-readline \
    --enable-scfilter && \
    grep -q '^#define FEAT_NTS' config.h

# Preserve DNS/NSS support in glibc while linking external libraries statically.
# Upstream Makefile links: LDFLAGS, LIBS, then EXTRA_LIBS/EXTRA_CLI_LIBS.
RUN make -j$(nproc) \
    LDFLAGS="-static-libgcc -Wl,-Bstatic" \
    LIBS="$(pkg-config --static --libs nettle gnutls) -lm" \
    EXTRA_LIBS="$(pkg-config --static --libs libcap libseccomp) -Wl,-Bdynamic" \
    EXTRA_CLI_LIBS="-Wl,-Bdynamic"

RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="chrony"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="chronyd time synchronization daemon and chronyc client"

COPY --from=build /src/target/ /target/
