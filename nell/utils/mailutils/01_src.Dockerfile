FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.21

RUN mkdir -p /src/mailutils && \
    wget -qO- https://ftp.gnu.org/gnu/mailutils/mailutils-${VERSION}.tar.xz | \
        tar -xJf - -C /src/mailutils --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
