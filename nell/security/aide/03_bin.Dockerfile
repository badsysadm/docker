ARG VERSION=0.19.4

FROM oci.badsysadm.local:80/dep/security/aide:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/aide

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --enable-static \
    --with-nettle \
    --without-gcrypt \
    --with-zlib \
    --with-posix-acl \
    --without-selinux \
    --without-xattr \
    --with-capabilities \
    --without-e2fsattrs \
    --without-curl \
    --without-audit \
    --without-locale

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share

FROM scratch AS bundle
LABEL org.opencontainers.image.title="aide"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="AIDE static bundle"

COPY --from=build /src/target/ /target/
