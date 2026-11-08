ARG VERSION=2.6.4

FROM oci.badsysadm.local:80/dep/dev/flex:${VERSION} AS build
ARG VERSION

WORKDIR /src/flex

RUN ./autogen.sh

RUN ./configure \
    --prefix=/usr \
    --disable-nls \
    LDFLAGS="-static-libgcc" \
    LIBS="-Wl,-Bstatic -lm -Wl,-Bdynamic"

RUN make -C src -j$(nproc)
RUN make -C src install DESTDIR=/src/target

RUN ln -s flex /src/target/usr/bin/flex++ && \
    rm -f /src/target/usr/lib/libfl.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="flex"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Fast lexical analyzer generator"
COPY --from=build /src/target/ /target/
