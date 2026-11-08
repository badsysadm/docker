ARG VERSION=4.99.7

FROM oci.badsysadm.local:80/dep/net/tcpdump:${VERSION} AS build
ARG VERSION

WORKDIR /src/tcpdump

COPY debian/patches /src/patches/
RUN git apply /src/patches/_static-pcap.patch

RUN cmake -S . -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_FIND_LIBRARY_SUFFIXES=.a \
    -DCRYPTO_ROOT=/usr/local \
    -DCRYPTO_INCLUDE_DIRS=/usr/local/include \
    -DCRYPTO_LIBRARIES="/usr/local/lib64/libcrypto.a;/usr/local/lib/libzstd.a;/usr/local/lib/libz.a" \
    -DWITH_CRYPTO=ON \
    -DWITH_CAP_NG=ON \
    -DWITH_SMI=OFF \
    -DENABLE_SMB=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc" \
    -DCMAKE_C_STANDARD_LIBRARIES="-Wl,-Bstatic -lcap-ng -lcap -Wl,-Bdynamic"

RUN cmake --build build -j$(nproc)
RUN DESTDIR=/src/target cmake --install build

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="tcpdump"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="TCP packet capture and protocol analysis utility"
COPY --from=build /src/target/ /target/
