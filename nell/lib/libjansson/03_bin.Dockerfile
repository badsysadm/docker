ARG VERSION=2.14.1

FROM oci.badsysadm.local:80/dep/lib/libjansson:${VERSION} AS build
ARG VERSION

WORKDIR /src/jansson

COPY debian/patches /src/patches/
RUN git apply /src/patches/_build.patch

RUN cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DJANSSON_BUILD_SHARED_LIBS=ON \
    -DJANSSON_BUILD_DOCS=OFF \
    -DJANSSON_WITHOUT_TESTS=ON

RUN cmake --build build -j$(nproc)
RUN DESTDIR=/src/target cmake --install build

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libjansson"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="JSON library"
COPY --from=build /src/target/ /target/
