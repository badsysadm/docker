ARG VERSION=4.11.0

FROM oci.badsysadm.local:80/dep/utils/findutils:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/findutils
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --sbindir=/sbin \
    --libdir=/usr/lib64 \
    --disable-nls

RUN make -j$(nproc)
RUN make DESTDIR=/src/target install
RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="findutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU findutils binaries"
COPY --from=build /src/target/ /target/
