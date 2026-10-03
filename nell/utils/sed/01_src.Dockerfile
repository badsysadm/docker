FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.9

RUN mkdir -p /src/sed && \
    wget -qO- https://ftp.gnu.org/gnu/sed/sed-${VERSION}.tar.xz | tar -xJf - -C /src/sed --strip-components=1

FROM scratch
COPY --from=build /src/sed/ /src
