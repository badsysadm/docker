FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=7.2

RUN mkdir -p /src/ethtool && \
    wget -qO- "https://www.kernel.org/pub/software/network/ethtool/ethtool-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/ethtool --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
