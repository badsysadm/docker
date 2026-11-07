ARG VERSION=3.15.0

FROM oci.badsysadm.local:80/dep/utils/pciutils:${VERSION} AS build
ARG VERSION

WORKDIR /src/pciutils
RUN make -j$(nproc) \
    PREFIX=/usr \
    SHARED=no ZLIB=no DNS=yes LIBKMOD=no HWDB=no \
    LDFLAGS="-static-libgcc" \
    lspci setpci pcilmr update-pciids

RUN install -D -m 0755 lspci /src/target/usr/bin/lspci
RUN install -D -m 0755 setpci /src/target/usr/sbin/setpci
RUN install -D -m 0755 pcilmr /src/target/usr/sbin/pcilmr
RUN install -D -m 0755 update-pciids /src/target/usr/sbin/update-pciids
RUN install -D -m 0644 pci.ids /src/target/usr/share/pci.ids

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="pciutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="PCI bus inspection and configuration utilities"
COPY --from=build /src/target/ /target/
