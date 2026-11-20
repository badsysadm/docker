ARG VERSION=3.3.8

FROM oci.badsysadm.local:80/dep/system/apt:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION
ENV SOURCE_DATE_EPOCH=1700000000

WORKDIR /src/apt

COPY debian/patches /src/patches/
RUN git apply /src/patches/_build_3.6.6.patch
RUN git apply /src/patches/_pax.patch

WORKDIR /src/apt/.build

RUN cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_NLS=OFF \
  -DWITH_DOC=OFF \
  -DOPENSSL_ROOT_DIR=/usr/local \
  -DOPENSSL_USE_STATIC_LIBS=TRUE \
  -DOPENSSL_SSL_LIBRARY=/usr/local/lib64/libssl.a \
  -DOPENSSL_CRYPTO_LIBRARY=/usr/local/lib64/libcrypto.a \
  -DCMAKE_C_FLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
  -DCMAKE_CXX_FLAGS="-O2 -fPIC -ffunction-sections -fdata-sections -std=c++23 -I/usr/local/include" \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--gc-sections -static-libgcc -static-libstdc++" \
  -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--gc-sections -static-libgcc -static-libstdc++" \
  -DCMAKE_CXX_STANDARD_LIBRARIES="-Wl,-Bstatic -Wl,--start-group /usr/local/lib/liblzma.a /usr/local/lib/libzstd.a /usr/local/lib/libbz2.a /usr/local/lib/liblz4.a /usr/local/lib/libz.a /usr/local/lib/libxxhash.a -ldb -lgcrypt /usr/local/lib64/libcrypto.a -Wl,--end-group -Wl,-Bdynamic -ldl -pthread"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="apt"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Low-level package manager"
COPY --from=build /src/target/ /target/
