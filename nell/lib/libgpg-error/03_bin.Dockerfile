ARG VERSION=1.51

FROM oci.badsysadm.local:80/dep/lib/libgpg-error:${VERSION} AS build
ARG VERSION

WORKDIR /src/libgpg-error
RUN ./autogen.sh
RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-static \
    --enable-shared \
    --with-pic \
    --disable-doc \
    --disable-tests \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-Wl,--gc-sections -Wl,-z,relro,-z,now"

RUN make -j$(nproc) gpg_error_LDFLAGS="-static-libtool-libs"
RUN make install DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/doc \
           /src/target/usr/share/man \
           /src/target/usr/share/info \
           /src/target/usr/share/gtk-doc \
           /src/target/usr/share/locale && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libgpg-error"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
COPY --from=build /src/target/ /target/
