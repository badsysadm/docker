ARG VERSION=8.23.0
ARG OPENSSL_VERSION=3.6.5
ARG LIBSSH2_VERSION=1.11.1
ARG ZLIB_VERSION=1.3.1
ARG NGHTTP2_VERSION=1.71.0

FROM oci.badsysadm.local:80/src/net/curl:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG OPENSSL_VERSION
ARG LIBSSH2_VERSION
ARG ZLIB_VERSION
ARG NGHTTP2_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN git clone -q --single-branch --branch "v${ZLIB_VERSION}" --depth 1 \
    https://github.com/madler/zlib.git /src/zlib && \
    cd /src/zlib && \
    CFLAGS="-O2 -fPIC" ./configure --prefix=/usr/local --static && \
    make -j$(nproc) && make install

RUN git clone -q --single-branch --branch "openssl-${OPENSSL_VERSION}" --depth 1 \
    https://github.com/openssl/openssl.git /src/openssl && \
    cd /src/openssl && \
    ./config no-shared no-tests enable-pic --prefix=/usr/local --libdir=lib && \
    make -j$(nproc) build_libs && make install_sw

RUN git clone -q --single-branch --branch "libssh2-${LIBSSH2_VERSION}" --depth 1 \
    https://github.com/libssh2/libssh2.git /src/libssh2 && \
    cmake -S /src/libssh2 -B /src/libssh2/build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCRYPTO_BACKEND=OpenSSL \
    -DOPENSSL_ROOT_DIR=/usr/local \
    -DOPENSSL_USE_STATIC_LIBS=TRUE && \
    cmake --build /src/libssh2/build -j$(nproc) && \
    cmake --install /src/libssh2/build

RUN git clone -q --single-branch --branch "v${NGHTTP2_VERSION}" --depth 1 \
    https://github.com/nghttp2/nghttp2.git /src/nghttp2 && \
    cd /src/nghttp2 && \
    autoreconf -i && \
    CFLAGS="-O2 -fPIC" ./configure --prefix=/usr/local --libdir=/usr/local/lib \
    --enable-static --disable-shared --disable-app \
    --disable-hpack-tools --disable-examples --disable-python-bindings && \
    make -j$(nproc) && make install

COPY --from=src_image /src/curl/ /src/curl/
