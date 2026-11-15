ARG VERSION=1.11.0

FROM oci.badsysadm.local:80/dep/lib/libgcrypt:${VERSION} AS build
ARG VERSION

WORKDIR /src/libgcrypt
RUN ./autogen.sh
RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-static \
    --enable-shared \
    --with-pic \
    --disable-doc \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-Wl,--gc-sections -Wl,-z,relro,-z,now"

RUN make -j$(nproc) mpicalc_LDADD=".libs/libgcrypt.a -lgpg-error"
RUN make install DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/doc \
           /src/target/usr/share/man \
           /src/target/usr/share/info \
           /src/target/usr/share/gtk-doc \
           /src/target/usr/share/locale && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libgcrypt"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
COPY --from=build /src/target/ /target/
