FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG OPENSSL_VERSION=3.6.5

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential ca-certificates wget perl pkg-config zlib1g-dev libzstd-dev

RUN mkdir -p /src /src/target

RUN wget -O- https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz | tar -xz -C /src

WORKDIR /src/openssl-${OPENSSL_VERSION}

RUN ./config \
    --prefix=/usr \
    --openssldir=/etc/ssl \
    --libdir=lib/x86_64-linux-gnu \
    shared \
    enable-zlib \
    enable-zstd \
    no-docs \
    no-tests \
    -static-libgcc

# 1. Замена zlib/zstd на статические .a архивы для libcrypto.so
RUN perl -pi -e 's/(CNF_EX_LIBS=.*)(-lz\b)/$1 \/usr\/lib\/x86_64-linux-gnu\/libz.a/g' Makefile && \
    perl -pi -e 's/(CNF_EX_LIBS=.*)(-lzstd\b)/$1 \/usr\/lib\/x86_64-linux-gnu\/libzstd.a/g' Makefile && \
    perl -pi -e 's/ EX_LIBS=-lz\b/ EX_LIBS=\/usr\/lib\/x86_64-linux-gnu\/libz.a/g' Makefile && \
    perl -pi -e 's/ EX_LIBS=-lzstd\b/ EX_LIBS=\/usr\/lib\/x86_64-linux-gnu\/libzstd.a/g' Makefile

# 2. Настройка статической сборки только для исполняемых файлов (BIN_LDFLAGS), не затрагивая shared-либы
RUN perl -pi -e 's/^BIN_LDFLAGS=/BIN_LDFLAGS=-static /g' Makefile && \
    perl -pi -e 's/apps\/openssl: (.*) libcrypto.so libssl.so/apps\/openssl: $1 libcrypto.a libssl.a/g' Makefile

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/doc /src/target/usr/share/man

FROM scratch AS bundle
LABEL org.opencontainers.image.title="openssl"
LABEL org.opencontainers.image.version="3.6.4"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="OpenSSL static binary with shared libraries containing embedded zlib and zstd"
COPY --from=build /src/target/ /
