FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3.2

RUN mkdir -p /src/libnftnl && \
    wget -qO- https://www.netfilter.org/pub/libnftnl/libnftnl-${VERSION}.tar.xz | \
        tar -xJf - -C /src/libnftnl --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
