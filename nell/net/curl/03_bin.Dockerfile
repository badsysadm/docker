ARG VERSION=8.23.0

FROM oci.badsysadm.local:80/dep/net/curl:${VERSION} AS build
ARG VERSION

WORKDIR /src/curl

RUN cmake -S . -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_STATIC_LIBS=ON \
    -DBUILD_STATIC_CURL=ON \
    -DCURL_USE_OPENSSL=ON \
    -DOPENSSL_USE_STATIC_LIBS=TRUE \
    -DOPENSSL_SSL_LIBRARY=/usr/local/lib/libssl.a \
    -DOPENSSL_CRYPTO_LIBRARY=/usr/local/lib/libcrypto.a \
    -DCURL_USE_LIBSSH2=ON \
    -DLIBSSH2_LIBRARY=/usr/local/lib/libssh2.a \
    -DUSE_NGHTTP2=ON \
    -DNGHTTP2_LIBRARY=/usr/local/lib/libnghttp2.a \
    -DCURL_ZLIB=ON \
    -DZLIB_LIBRARY=/usr/local/lib/libz.a \
    -DCURL_USE_LIBPSL=OFF \
    -DCURL_BROTLI=OFF \
    -DCURL_ZSTD=OFF \
    -DBUILD_TESTING=OFF \
    -DENABLE_CURL_MANUAL=OFF \
    -DBUILD_LIBCURL_DOCS=OFF \
    -DBUILD_MISC_DOCS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc" && \
    cmake --build build -j$(nproc) && \
    DESTDIR=/src/target cmake --install build

RUN install -D -m 0755 scripts/wcurl /src/target/usr/bin/wcurl && \
    rm -rf /src/target/usr/share/doc /src/target/usr/share/man \
    /src/target/usr/share/info

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="curl"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="curl, libcurl and wcurl"
COPY --from=build /src/target/ /target/
