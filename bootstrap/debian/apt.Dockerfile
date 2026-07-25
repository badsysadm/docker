FROM mirror.gcr.io/library/debian:trixie
ARG APT_VERSION=3.3.1
ARG OPENSSL_VERSION=openssl-3.4.1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential cmake pkg-config gettext triehash \
    liblzma-dev libzstd-dev libbz2-dev liblz4-dev zlib1g-dev \
    libgcrypt20-dev libxxhash-dev libdb-dev \
    git ca-certificates perl

RUN git clone --single-branch --branch ${OPENSSL_VERSION} --depth 1 https://github.com/openssl/openssl.git /src/openssl
WORKDIR /src/openssl
RUN ./config no-shared no-tests --prefix=/usr/local --openssldir=/usr/local/ssl
RUN make -j$(nproc)
RUN make build_libs
RUN make install_sw

RUN git clone --single-branch --branch ${APT_VERSION} --depth 1 https://salsa.debian.org/apt-team/apt.git /src/apt
WORKDIR /src/apt

COPY apt.patches /src/

RUN git apply /src/apt.patches

#RUN sed -i '/add_subdirectory(test)/d' CMakeLists.txt

# Переводим внутренние библиотеки APT в STATIC с поддержкой -fPIC
#RUN sed -i 's/add_library(apt-pkg SHARED/add_library(apt-pkg STATIC/g' ./apt-pkg/CMakeLists.txt
#RUN sed -i 's/add_library(apt-private SHARED/add_library(apt-private STATIC/g' ./apt-private/CMakeLists.txt
#RUN sed -i '/add_library(apt-pkg STATIC/a set_property(TARGET apt-pkg PROPERTY POSITION_INDEPENDENT_CODE ON)' ./apt-pkg/CMakeLists.txt
#RUN sed -i '/add_library(apt-private STATIC/a set_property(TARGET apt-private PROPERTY POSITION_INDEPENDENT_CODE ON)' ./apt-private/CMakeLists.txt

# Ищем только статические .a файлы для всех find_package
#RUN sed -i '1i set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")' ./CMakeLists.txt

# ИСКЛЮЧЕНИЕ: Разрешаем динамический поиск (.so) только для системных потоков Threads (pthread)
#RUN sed -i '/find_package(Threads REQUIRED)/i set(CMAKE_FIND_LIBRARY_SUFFIXES ".so" ".a")' ./CMakeLists.txt
#RUN sed -i '/find_package(Threads REQUIRED)/a set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")' ./CMakeLists.txt

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
RUN make install DESTDIR=/usr/local
