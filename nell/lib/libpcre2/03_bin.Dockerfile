ARG VERSION=10.49

FROM oci.badsysadm.local:80/dep/lib/libpcre2:${VERSION} AS build
ARG VERSION

WORKDIR /src/pcre2

RUN cmake -S . -B build-static \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_STATIC_LIBS=ON \
    -DPCRE2_STATIC_PIC=ON \
    -DPCRE2_BUILD_TESTS=OFF \
    -DPCRE2_SUPPORT_JIT=ON \
    -DZLIB_INCLUDE_DIR=/usr/local/include \
    -DZLIB_LIBRARY=/usr/local/lib/libz.a \
    -DBZIP2_LIBRARY_RELEASE=/usr/lib/x86_64-linux-gnu/libbz2.a \
    -DPCRE2_SUPPORT_LIBREADLINE=OFF

RUN cmake --build build-static -j$(nproc)
RUN DESTDIR=/src/target cmake --install build-static

RUN cmake -S . -B build-shared \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DPCRE2_BUILD_PCRE2GREP=OFF \
    -DPCRE2_BUILD_TESTS=OFF \
    -DPCRE2_SUPPORT_JIT=ON

RUN cmake --build build-shared -j$(nproc)
RUN DESTDIR=/src/target cmake --install build-shared

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libpcre2"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Perl-compatible regular expressions library"
COPY --from=build /src/target/ /target/
