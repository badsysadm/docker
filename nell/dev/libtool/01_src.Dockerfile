FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.6.2

RUN mkdir -p /src/libtool && \
    wget -qO- "https://ftp.gnu.org/gnu/libtool/libtool-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/libtool --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
