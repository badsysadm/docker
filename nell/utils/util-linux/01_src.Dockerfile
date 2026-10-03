FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.42.2

RUN export UTIL_LINUX_MAJOR=$(echo v${VERSION} | cut -d. -f1-2) && \
    mkdir -p /src/util-linux && \
    wget -qO- https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/${UTIL_LINUX_MAJOR}/util-linux-${VERSION}.tar.xz | tar -xJf - -C /src/util-linux --strip-components=1

FROM scratch
COPY --from=build /src/util-linux/ /src
