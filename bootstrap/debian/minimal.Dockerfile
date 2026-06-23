FROM mirror.gcr.io/library/debian:trixie
ARG APT_VERSION=3.3.1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential cmake pkg-config gettext triehash \
    liblzma-dev libzstd-dev libbz2-dev liblz4-dev zlib1g-dev \
    libgcrypt20-dev libxxhash-dev libdb-dev libssl-dev \
    git ca-certificates
RUN git clone --single-branch --branch ${APT_VERSION} --depth 1 https://salsa.debian.org/apt-team/apt.git /src/apt
WORKDIR /src/apt
RUN sed -i '/add_subdirectory(test)/d' CMakeLists.txt

RUN sed -i 's/add_library(apt-pkg SHARED/add_library(apt-pkg STATIC/g' ./apt-pkg/CMakeLists.txt
RUN sed -i 's/add_library(apt-private SHARED/add_library(apt-private STATIC/g' ./apt-private/CMakeLists.txt
RUN sed -i '/add_library(apt-pkg STATIC/a set_property(TARGET apt-pkg PROPERTY POSITION_INDEPENDENT_CODE ON)' ./apt-pkg/CMakeLists.txt
RUN sed -i '/add_library(apt-private STATIC/a set_property(TARGET apt-private PROPERTY POSITION_INDEPENDENT_CODE ON)' ./apt-private/CMakeLists.txt

RUN sed -i 's/target_link_libraries(\${exe} PRIVATE/target_link_libraries(\${exe} PRIVATE -Wl,-Bstatic ${LZMA_LIBRARIES} ${ZSTD_LIBRARIES} ${LZ4_LIBRARIES} ${BZIP2_LIBRARIES} ${ZLIB_LIBRARIES} ${XXHASH_LIBRARIES} ${BERKELEY_LIBRARIES} ${GCRYPT_LIBRARIES} -Wl,-Bdynamic/g' ./cmdline/CMakeLists.txt

WORKDIR /src/apt/.build
RUN cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_NLS=OFF \
  -DWITH_DOC=OFF \
  -DCMAKE_CXX_FLAGS="-std=c++23 -static-libgcc -static-libstdc++" \
  -DLZMA_LIBRARIES=/usr/lib/x86_64-linux-gnu/liblzma.a \
  -DZSTD_LIBRARIES=/usr/lib/x86_64-linux-gnu/libzstd.a \
  -DLZ4_LIBRARIES=/usr/lib/x86_64-linux-gnu/liblz4.a \
  -DBZIP2_LIBRARIES=/usr/lib/x86_64-linux-gnu/libbz2.a \
  -DZLIB_LIBRARIES=/usr/lib/x86_64-linux-gnu/libz.a \
  -DXXHASH_LIBRARIES=/usr/lib/x86_64-linux-gnu/libxxhash.a \
  -DBERKELEY_LIBRARIES=/usr/lib/x86_64-linux-gnu/libdb.a
RUN make -j$(nproc)
RUN make install DESTDIR=/usr/local
