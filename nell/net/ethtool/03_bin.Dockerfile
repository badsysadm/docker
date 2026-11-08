ARG VERSION=7.2

FROM oci.badsysadm.local:80/dep/net/ethtool:${VERSION} AS build
ARG VERSION

WORKDIR /src/ethtool

RUN ./configure \
    --prefix=/usr \
    --sbindir=/usr/sbin \
    --enable-netlink \
    --enable-pretty-dump \
    --with-bash-completion-dir=no \
    LDFLAGS="-L/usr/local/lib -static-libgcc" \
    MNL_LIBS="-Wl,-Bstatic -lmnl -Wl,-Bdynamic"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/metainfo

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="ethtool"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Ethernet device configuration and diagnostics"
COPY --from=build /src/target/ /target/
