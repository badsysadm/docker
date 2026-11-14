ARG VERSION=0.8.5

FROM oci.badsysadm.local:80/dep/lib/libcap-ng:${VERSION} AS build
ARG VERSION

WORKDIR /src/libcap-ng

RUN ./autogen.sh

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-static \
    --enable-shared \
    --with-pic \
    --without-python3 \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libcap-ng"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux capabilities library and utilities"
COPY --from=build /src/target/ /target/
