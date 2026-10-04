FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.10.0

RUN mkdir -p /src/kbd /src/target && \
    wget -qO- https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-${VERSION}.tar.xz | tar -xJf - -C /src/kbd --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
