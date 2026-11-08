ARG VERSION=4.4.5

FROM oci.badsysadm.local:80/dep/dev/cmake:${VERSION} AS build
ARG VERSION

WORKDIR /src/cmake

RUN mkdir build
WORKDIR /src/cmake/build

RUN CXXFLAGS="-O2" \
    LDFLAGS="-static-libstdc++ -static-libgcc" \
    ../bootstrap \
    --prefix=/usr \
    --parallel=$(nproc) \
    --no-system-libs \
    -- \
    -DBUILD_TESTING=OFF \
    -DCMAKE_USE_OPENSSL=ON \
    -DOPENSSL_ROOT_DIR=/usr/local \
    -DOPENSSL_USE_STATIC_LIBS=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc" \
    -DSPHINX_HTML=OFF \
    -DSPHINX_MAN=OFF

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/doc \
    /src/target/usr/share/info

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="cmake"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="CMake build tools including CTest and CPack"
COPY --from=build /src/target/ /target/
