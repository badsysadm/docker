ARG VERSION=5.6.2

FROM oci.badsysadm.local:80/dep/utils/xzutils:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/xzutils
RUN cmake -B build \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_NLS=OFF \
    -DXZ_DOC=OFF \
    -DXZ_DOXYGEN=OFF

RUN cmake --build build -j$(nproc)
RUN DESTDIR=/src/target cmake --install build

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="xzutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="XZ and LXMZ binaries and libs"
COPY --from=build /src/target/ /target/
