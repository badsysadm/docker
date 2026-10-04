FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.35

RUN mkdir -p /src/tar /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/tar/tar-${VERSION}.tar.gz | tar -xzf - -C /src/tar --strip-components=1

FROM scratch
COPY --from=build /src/ /src