FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG CURL_VERSION=curl-8_21_0
ARG OPENSSL_VERSION=openssl-3.4.1
ARG LIBSSH2_VERSION=libssh2-1.11.1
ARG ZLIB_VERSION=v1.3.1
ARG NGHTTP2_VERSION=v1.64.0

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext ca-certificates wget git perl \
    cmake ninja-build automake autoconf libtool

RUN mkdir -p /src /src/curl /src/target

# 1. zlib (статическая сборка из git)
RUN git clone --single-branch --branch ${ZLIB_VERSION} --depth 1 https://github.com/madler/zlib.git /src/zlib && \
    cd /src/zlib && \
    ./configure --prefix=/usr/local --static && \
    make -j$(nproc) && \
    make install

# 2. OpenSSL (статическая сборка из git)
RUN git clone --single-branch --branch ${OPENSSL_VERSION} --depth 1 https://github.com/openssl/openssl.git /src/openssl && \
    cd /src/openssl && \
    ./config no-shared no-tests --prefix=/usr/local --openssldir=/usr/local/ssl && \
    make -j$(nproc) build_libs && \
    make install_sw

# 3. libssh2 (статическая сборка из git)
RUN git clone --single-branch --branch ${LIBSSH2_VERSION} --depth 1 https://github.com/libssh2/libssh2.git /src/libssh2 && \
    cd /src/libssh2 && \
    cmake -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCRYPTO_BACKEND=OpenSSL && \
    cmake --build build -j$(nproc) && \
    cmake --install build

# 4. nghttp2 (статическая сборка из git через autoreconf/configure для надёжного .a)
RUN git clone --single-branch --branch ${NGHTTP2_VERSION} --depth 1 https://github.com/nghttp2/nghttp2.git /src/nghttp2 && \
    cd /src/nghttp2 && \
    autoreconf -i && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib --enable-static --disable-shared --disable-app --disable-hpack-tools --disable-examples --disable-python-bindings && \
    make -j$(nproc) && \
    make install

# 5. curl (статическая сборка из git)
RUN git clone --single-branch --branch ${CURL_VERSION} --depth 1 https://github.com/curl/curl.git /src/curl

WORKDIR /src/curl

RUN cmake -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_STATIC_LIBS=ON \
    -DBUILD_STATIC_CURL=ON \
    -DCURL_USE_OPENSSL=ON \
    -DCURL_USE_LIBSSH2=ON \
    -DUSE_NGHTTP2=ON \
    -DCURL_USE_LIBPSL=OFF \
    -DBUILD_TESTING=OFF \
    -DENABLE_CURL_MANUAL=OFF \
    -DBUILD_LIBCURL_DOCS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static" && \
    cmake --build build -j$(nproc) && \
    DESTDIR=/src/target cmake --install build

RUN install -D -m 755 scripts/wcurl /src/target/usr/bin/wcurl

FROM scratch AS bundle
LABEL org.opencontainers.image.title="curl"
LABEL org.opencontainers.image.version="8.12.1"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="curl binary and tools"
COPY --from=build /src/target/ /
