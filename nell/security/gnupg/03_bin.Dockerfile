ARG VERSION=2.4.7

FROM oci.badsysadm.local:80/dep/utils/gnupg:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/gnupg

RUN sed -i 's/ZLIBS="-lz"/ZLIBS="\/usr\/lib\/x86_64-linux-gnu\/libz.a"/g' configure.ac
RUN sed -i 's/ZLIBS="$ZLIBS -lbz2"/ZLIBS="$ZLIBS \/usr\/lib\/x86_64-linux-gnu\/libbz2.a"/g' configure.ac

RUN ./autogen.sh

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-nls \
    --disable-scdaemon \
    --disable-gpgsm \
    --disable-dirmngr \
    --enable-maintainer-mode \
    --with-libgpg-error-prefix=/usr/local \
    --with-libgcrypt-prefix=/usr/local \
    --with-libassuan-prefix=/usr/local \
    --with-libksba-prefix=/usr/local \
    --with-npth-prefix=/usr/local \
    CFLAGS="-O2" \
    LDFLAGS="-static-libgcc -static-libstdc++"

RUN make
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="gnupg"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Cryptographic software suite"
COPY --from=build /src/target/ /target/
