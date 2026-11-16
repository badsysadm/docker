ARG VERSION=2.5.24

FROM oci.badsysadm.local:80/dep/security/gnupg:${VERSION} AS build
ARG VERSION

WORKDIR /src/gnupg
RUN ./autogen.sh
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --enable-maintainer-mode \
    --disable-doc \
    --disable-nls \
    --disable-scdaemon \
    --disable-gpgsm \
    --disable-dirmngr \
    --with-libgpg-error-prefix=/usr \
    --with-libgcrypt-prefix=/usr \
    --with-libassuan-prefix=/usr \
    --with-libksba-prefix=/usr \
    --with-npth-prefix=/usr \
    CFLAGS="-O2 -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc -Wl,--gc-sections -Wl,-Bstatic" \
    LIBS="-Wl,-Bdynamic -ldl -lm -pthread"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/man \
           /src/target/usr/share/info \
           /src/target/usr/share/doc \
           /src/target/usr/share/gnupg

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="gnupg"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Cryptographic software suite"
COPY --from=build /src/target/ /target/
