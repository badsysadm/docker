FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.47

RUN mkdir -p /src/binutils && \
    wget -qO- https://sourceware.org/pub/binutils/releases/binutils-${VERSION}.tar.xz | \
        tar -xJf - -C /src/binutils --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
