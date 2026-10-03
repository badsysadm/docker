ARG VERSION=3.6.5

FROM oci.badsysadm.local:80/dep/security/openssl:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION
ARG SOURCE_DATE_EPOCH=0

WORKDIR /src/openssl

RUN ./config \
    --prefix=/usr \
    --openssldir=/etc/ssl \
    shared \
    enable-zlib \
    enable-zstd \
    no-docs \
    no-tests \
    -static-libgcc

RUN perl -pi -e 's/(CNF_EX_LIBS=.*)(-lz\b)/$1 \/usr\/lib\/x86_64-linux-gnu\/libz.a/g' Makefile && \
    perl -pi -e 's/(CNF_EX_LIBS=.*)(-lzstd\b)/$1 \/usr\/lib\/x86_64-linux-gnu\/libzstd.a/g' Makefile && \
    perl -pi -e 's/ EX_LIBS=-lz\b/ EX_LIBS=\/usr\/lib\/x86_64-linux-gnu\/libz.a/g' Makefile && \
    perl -pi -e 's/ EX_LIBS=-lzstd\b/ EX_LIBS=\/usr\/lib\/x86_64-linux-gnu\/libzstd.a/g' Makefile

RUN perl -pi -e 's/^BIN_LDFLAGS=/BIN_LDFLAGS=-static /g' Makefile && \
    perl -pi -e 's/apps\/openssl: (.*) libcrypto.so libssl.so/apps\/openssl: $1 libcrypto.a libssl.a/g' Makefile

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/doc /src/target/usr/share/man

FROM scratch AS bundle 
LABEL org.opencontainers.image.title="openssl" 
LABEL org.opencontainers.image.version=${VERSION} 
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>" 
LABEL org.opencontainers.image.description="openssl static bundle" 

COPY --from=build /src/target/ /target/
