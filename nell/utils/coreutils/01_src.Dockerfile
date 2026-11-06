FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=9.5

RUN mkdir -p /src/coreutils /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/coreutils/coreutils-${VERSION}.tar.xz | tar -xJf - -C /src/coreutils --strip-components=1

FROM scratch
COPY --from=build /src/ /src