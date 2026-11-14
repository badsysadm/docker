ARG VERSION=1.14.1

FROM oci.badsysadm.local:80/dep/lib/libmaxminddb:${VERSION} AS build
ARG VERSION

WORKDIR /src/libmaxminddb

RUN cmake -S . -B build-static \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DPERL:FILEPATH=""

RUN cmake --build build-static -j$(nproc)
RUN DESTDIR=/src/target cmake --install build-static

RUN cmake -S . -B build-shared \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DMAXMINDDB_BUILD_BINARIES=OFF \
    -DPERL:FILEPATH=""

RUN cmake --build build-shared -j$(nproc)
RUN DESTDIR=/src/target cmake --install build-shared

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libmaxminddb"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="MaxMind DB lookup library"
COPY --from=build /src/target/ /target/
