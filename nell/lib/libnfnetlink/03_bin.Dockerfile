ARG VERSION=1.0.2

FROM oci.badsysadm.local:80/dep/lib/libnfnetlink:${VERSION} AS build
ARG VERSION

WORKDIR /src/libnfnetlink

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --enable-static \
    --enable-shared \
    --with-pic \
    CFLAGS="-O2 -fPIC"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/x86_64-linux-gnu/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libnfnetlink"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="libnfnetlink static and shared libraries"
COPY --from=build /src/target/ /target/
