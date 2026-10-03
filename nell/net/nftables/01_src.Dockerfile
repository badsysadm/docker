FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.1.7

RUN mkdir -p /src/nftables && \
    wget -qO- https://www.netfilter.org/pub/nftables/nftables-${VERSION}.tar.xz | \
        tar -xJf - -C /src/nftables --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
