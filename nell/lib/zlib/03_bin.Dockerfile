ARG VERSION=1.3.1

FROM oci.badsysadm.local:80/dep/lib/zlib:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/zlib

RUN CFLAGS="-O2 -fPIC" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="zlib"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="zlib compression library"
COPY --from=build /src/target/ /target/
