ARG VERSION=1.35

FROM oci.badsysadm.local:80/dep/utils/tar:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION
ARG FORCE_UNSAFE_CONFIGURE=1

WORKDIR /src/tar

COPY debian/patches /src/patches/
RUN patch -p0 < /src/patches/_build.patch

RUN autoreconf -f -i
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-nls \
    --without-selinux \
    --with-gzip=gzip \
    --with-bzip2=bzip2 \
    --with-xz=xz \
    --with-lzma=lzma \
    --with-lzop=lzop \
    --with-zstd=zstd

RUN make -j$(nproc) V=1
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="tar"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Tape Archiver"
COPY --from=build /src/target/ /target/
