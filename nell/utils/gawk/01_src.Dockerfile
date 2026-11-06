FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=5.4.1

RUN mkdir -p /src/gawk /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/gawk/gawk-${VERSION}.tar.xz | tar -xJf - -C /src/gawk --strip-components=1

FROM scratch
COPY --from=build /src/ /src