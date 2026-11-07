ARG VERSION=8.23.0
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7

FROM oci.badsysadm.local:80/src/net/curl:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/local/lib64/libssl.a
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib64/libcrypto.a
COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a

COPY --from=zstd_image /target/usr/include/zstd.h /usr/local/include/zstd.h
COPY --from=zstd_image /target/usr/include/zstd_errors.h /usr/local/include/zstd_errors.h
COPY --from=zstd_image /target/usr/include/zdict.h /usr/local/include/zdict.h
COPY --from=zstd_image /target/usr/lib/x86_64-linux-gnu/libzstd.a /usr/local/lib/libzstd.a

COPY --from=src_image /src/ /src/

RUN cmake -S /src/libssh2 -B /src/libssh2/build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCRYPTO_BACKEND=OpenSSL \
    -DOPENSSL_ROOT_DIR=/usr/local \
    -DOPENSSL_USE_STATIC_LIBS=TRUE \
    -DOPENSSL_SSL_LIBRARY=/usr/local/lib64/libssl.a \
    -DOPENSSL_CRYPTO_LIBRARY=/usr/local/lib64/libcrypto.a && \
    cmake --build /src/libssh2/build -j$(nproc) && \
    cmake --install /src/libssh2/build

RUN cd /src/nghttp2 && \
    autoreconf -i && \
    CFLAGS="-O2 -fPIC" ./configure \
    --prefix=/usr/local --libdir=/usr/local/lib \
    --enable-static --disable-shared --disable-app \
    --disable-hpack-tools --disable-examples --disable-python-bindings && \
    make -j$(nproc) && make install
