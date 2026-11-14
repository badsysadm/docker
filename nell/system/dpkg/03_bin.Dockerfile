ARG VERSION=1.22.11

FROM oci.badsysadm.local:80/dep/system/dpkg:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/dpkg

COPY debian/patches /src/patches/
RUN git apply /src/patches/_build.patch
RUN git apply /src/patches/_pax.patch

RUN autoreconf -f -i

RUN CFLAGS="-O2 -fPIC" ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-shared \
    --with-libz=static \
    --with-libz-ng=no \
    --with-liblzma=static \
    --with-libzstd=static \
    --with-libbz2=static \
    --without-libselinux \
    --enable-static \
    --disable-dselect \
    --disable-start-stop-daemon \
    --enable-update-alternatives \
    --disable-devel-docs \
    --disable-nls

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc
RUN find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
LABEL org.opencontainers.image.title="dpkg"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Low-level package manager"
COPY --from=build /src/target/ /target/
