FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=7.2.0

RUN mkdir -p /src/iproute2 /src/target && \
    wget -qO- https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-${VERSION}.tar.xz | \
        tar -xJf - -C /src/iproute2 --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
