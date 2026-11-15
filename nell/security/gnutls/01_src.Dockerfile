FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.8.13

RUN mkdir -p /src/gnutls && \
    SERIES="${VERSION%.*}" && \
    wget --tries=3 -nv -O- "https://www.gnupg.org/ftp/gcrypt/gnutls/v${SERIES}/gnutls-${VERSION}.tar.xz" 2>/tmp/gnutls-wget.err | \
    tar -xJf - -C /src/gnutls --strip-components=1 || { cat /tmp/gnutls-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
