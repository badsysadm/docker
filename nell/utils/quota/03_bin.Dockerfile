ARG VERSION=4.11

FROM oci.badsysadm.local:80/dep/utils/quota:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/quota

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --disable-nls \
    --disable-rpc \
    --disable-netlink \
    --disable-ldapmail \
    --disable-libwrap \
    --enable-ext2direct \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="quota"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux filesystem disk quota utilities"

COPY --from=build /src/target/ /target/
