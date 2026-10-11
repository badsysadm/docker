FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.8.13

RUN mkdir -p /src/gnutls && \
    wget -qO- "https://ftp.gnu.org/gnu/gnutls/gnutls-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/gnutls --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
