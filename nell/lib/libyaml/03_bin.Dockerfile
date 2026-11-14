ARG VERSION=0.2.5

FROM oci.badsysadm.local:80/dep/lib/libyaml:${VERSION} AS build
ARG VERSION

WORKDIR /src/libyaml

RUN ./bootstrap

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-static \
    --enable-shared \
    --with-pic \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections"

RUN make -j$(nproc) -C src
RUN make -C include install DESTDIR=/src/target
RUN make -C src install DESTDIR=/src/target
RUN make yaml-0.1.pc
RUN install -D -m 0644 yaml-0.1.pc /src/target/usr/lib/pkgconfig/yaml-0.1.pc

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libyaml"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="YAML parser and emitter library"
COPY --from=build /src/target/ /target/
