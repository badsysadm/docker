FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.11.0

RUN mkdir -p /src/findutils /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/findutils/findutils-${VERSION}.tar.xz | tar -xJf - -C /src/findutils --strip-components=1

FROM scratch
COPY --from=build /src/ /src