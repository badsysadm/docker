ARG VERSION=1.8.1.3

FROM oci.badsysadm.local:80/dep/net/socat:${VERSION} AS build
ARG VERSION
ARG SOURCE_DATE_EPOCH=0
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}

WORKDIR /src/socat

RUN ./configure \
    --prefix=/usr \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib64 -L/usr/local/lib -static-libgcc" \
    LIBS="-Wl,-Bstatic -lssl -lcrypto -lzstd -lz -lreadline -lncursesw -lwrap -Wl,-Bdynamic" && \
    grep -q '^#define WITH_OPENSSL 1$' config.h

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="socat"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Multipurpose bidirectional data relay"
COPY --from=build /src/target/ /target/
