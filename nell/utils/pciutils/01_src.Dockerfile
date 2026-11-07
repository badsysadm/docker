FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.15.0

RUN mkdir -p /src/pciutils && \
    wget -qO- "https://mirrors.edge.kernel.org/pub/software/utils/pciutils/pciutils-${VERSION}.tar.xz" \
    | tar -xJf - -C /src/pciutils --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
