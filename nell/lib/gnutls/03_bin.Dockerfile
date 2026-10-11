ARG VERSION=3.8.13

FROM oci.badsysadm.local:80/dep/lib/gnutls:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/gnutls

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --enable-static \
    --enable-shared \
    --without-p11-kit \
    --without-tpm \
    --without-tpm2 \
    --disable-doc \
    --disable-tools \
    --disable-tests \
    --disable-nls

RUN make -j$(nproc)
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
