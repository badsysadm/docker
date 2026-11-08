FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.19

RUN mkdir -p /src/automake && \
    wget -qO- "https://ftp.gnu.org/gnu/automake/automake-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/automake --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
