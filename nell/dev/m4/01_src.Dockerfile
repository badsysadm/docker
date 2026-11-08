FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.4.21

RUN mkdir -p /src/m4 && \
    wget -qO- "https://ftp.gnu.org/gnu/m4/m4-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/m4 --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
