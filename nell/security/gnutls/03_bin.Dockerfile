ARG VERSION=3.8.13

FROM oci.badsysadm.local:80/dep/security/gnutls:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/gnutls

RUN find . -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-static \
    --enable-shared \
    --with-pic \
    --without-p11-kit \
    --without-tpm \
    --without-tpm2 \
    --disable-doc \
    --enable-tools \
    --disable-tests \
    --disable-nls \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-Wl,--gc-sections"

RUN make -j$(nproc)

# Re-link CLI programs against the static libtool archives while preserving
# both libgnutls.a and libgnutls.so for external consumers.
RUN make -C src clean && \
    make -j$(nproc) -C src \
        LDFLAGS="-static-libtool-libs -static-libgcc -Wl,--gc-sections -Wl,-Bstatic" \
        LIBS="-Wl,-Bstatic $(sed -n 's/^LIBS = //p' src/Makefile) -Wl,-Bdynamic"

RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/doc \
           /src/target/usr/share/man \
           /src/target/usr/share/info \
           /src/target/usr/share/locale \
           /src/target/usr/share/gtk-doc && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
LABEL org.opencontainers.image.title="gnutls"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GnuTLS library without PKCS#11 support"
COPY --from=build /src/target/ /target/
