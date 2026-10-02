ARG VERSION=1.22.11

FROM oci.badsysadm.local:80/dep/system/apt:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/openssl

RUN ./config no-shared no-tests --prefix=/usr/local
RUN make -j$(nproc)
RUN make build_libs
RUN make install_sw

WORKDIR /src/apt

COPY debian/patches /src/patches/
RUN git apply /src/patches/_build.patch
RUN git apply /src/patches/_pax.patch

WORKDIR /src/apt/.build

RUN cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_NLS=OFF \
  -DWITH_DOC=OFF \
  -DOPENSSL_ROOT_DIR=/usr/local \
  -DOPENSSL_USE_STATIC_LIBS=TRUE \
  -DCMAKE_CXX_FLAGS="-std=c++23" \
  -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic -llzma -lzstd -lbz2 -llz4 -lz -lxxhash -ldb -lgcrypt /usr/local/lib64/libcrypto.a -ldl -pthread -Wl,-Bdynamic"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="apt"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Low-level package manager"
COPY --from=build /src/target/ /target/
