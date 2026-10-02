ARG VERSION=5.3

FROM oci.badsysadm.local:80/dep/usr/bash:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/bash

RUN ./configure \
    --prefix=/usr \
    --bindir=/bin \
    --without-bash-malloc \
    --enable-static-link \
    --enable-mem-scramble \
    --enable-net-redirections \
    --enable-xpg-echo-default \
    --disable-help-builtin \
    --enable-year2038 \
    --disable-nls \
    --disable-rpath \
    CC="gcc -static" \
    LDFLAGS="-static"
RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="bash"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Bourne-Again SHell statically linked"
COPY --from=build /src/target/ /target/
