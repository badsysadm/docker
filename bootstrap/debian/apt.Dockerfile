FROM mirror.gcr.io/library/debian:trixie AS build
ARG APT_VERSION=3.3.1
ARG OPENSSL_VERSION=openssl-3.4.1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential cmake pkg-config gettext triehash \
    liblzma-dev libzstd-dev libbz2-dev liblz4-dev zlib1g-dev \
    libgcrypt20-dev libxxhash-dev libdb-dev \
    git ca-certificates perl

RUN git clone --single-branch --branch ${OPENSSL_VERSION} --depth 1 https://github.com/openssl/openssl.git /src/openssl
RUN mkdir -p /src/target
WORKDIR /src/openssl

RUN ./config no-shared no-tests --prefix=/usr/local
RUN make -j$(nproc)
RUN make build_libs
RUN make install_sw

RUN git clone --single-branch --branch ${APT_VERSION} --depth 1 https://salsa.debian.org/apt-team/apt.git /src/apt
WORKDIR /src/apt

COPY apt.patches /src/

RUN git apply /src/apt.patches

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

FROM scratch AS bundle
LABEL org.opencontainers.image.title="apt"
LABEL org.opencontainers.image.version="3.3.1"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="High-level package manager"
COPY --from=build /src/target/ /
