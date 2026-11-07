ARG VERSION=3.15.0

FROM oci.badsysadm.local:80/dep/utils/pciutils:${VERSION} AS build
ARG VERSION

WORKDIR /src/pciutils
RUN make -j$(nproc) \
    PREFIX=/usr \
    SHARED=no ZLIB=yes DNS=yes LIBKMOD=yes HWDB=yes \
    PKG_CONFIG=pkg-config \
    LIBZ="-Xlinker -Bstatic -lz -Xlinker -Bdynamic" \
    LDFLAGS="-static-libgcc -L/usr/lib/x86_64-linux-gnu" \
    LIBUDEV="-Xlinker -Bstatic -ludev -lcap -lblkid -llz4 -lzstd -llzma -lz -lcrypto -Xlinker -Bdynamic -ldl -lpthread" \
    LIBKMOD_LIBS="-Xlinker -Bstatic -lkmod -llzma -lcrypto -lzstd -lz -Xlinker -Bdynamic -ldl -lpthread" \
    lspci setpci pcilmr update-pciids pci.ids.gz

RUN install -D -m 0755 lspci /src/target/usr/bin/lspci
RUN install -D -m 0755 setpci /src/target/usr/sbin/setpci
RUN install -D -m 0755 pcilmr /src/target/usr/sbin/pcilmr
RUN install -D -m 0755 update-pciids /src/target/usr/sbin/update-pciids
RUN install -D -m 0644 pci.ids.gz /src/target/usr/share/pci.ids.gz

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="pciutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="PCI bus inspection and configuration utilities"
COPY --from=build /src/target/ /target/
