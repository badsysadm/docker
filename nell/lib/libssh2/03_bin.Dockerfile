ARG VERSION=1.11.1

FROM oci.badsysadm.local:80/dep/lib/libssh2:${VERSION} AS build
ARG VERSION

WORKDIR /src/libssh2

RUN cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_C_FLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--gc-sections -Wl,--exclude-libs,ALL" \
    -DBUILD_STATIC_LIBS=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCRYPTO_BACKEND=OpenSSL \
    -DOPENSSL_ROOT_DIR=/usr/local \
    -DOPENSSL_USE_STATIC_LIBS=TRUE \
    -DOPENSSL_SSL_LIBRARY=/usr/local/lib64/libssl.a \
    -DOPENSSL_CRYPTO_LIBRARY=/usr/local/lib64/libcrypto.a

RUN cmake --build build -j$(nproc)
RUN DESTDIR=/src/target cmake --install build
RUN rm -rf /src/target/usr/share/doc /src/target/usr/share/man /src/target/usr/share/info

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libssh2"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="SSH2 client library, static and shared"
COPY --from=build /src/target/ /target/
