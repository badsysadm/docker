FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.8.2

RUN mkdir -p /src/bison && \
    wget -qO- "https://ftp.gnu.org/gnu/bison/bison-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/bison --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
