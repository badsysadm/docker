FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.12

RUN mkdir -p /src/diffutils && \
    wget -qO- https://ftp.gnu.org/gnu/diffutils/diffutils-${VERSION}.tar.xz | tar -xJf - -C /src/diffutils --strip-components=1

FROM scratch
COPY --from=build /src/ /src
