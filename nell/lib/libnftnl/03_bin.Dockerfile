ARG VERSION=1.3.2

FROM oci.badsysadm.local:80/dep/lib/libnftnl:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/libnftnl

RUN ./configure \
        --prefix=/usr \
        --enable-static \
        --disable-shared

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="libnftnl"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="libnftnl static bundle"

COPY --from=build /src/target/ /target/
