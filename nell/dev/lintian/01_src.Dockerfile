FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.142.0

RUN mkdir -p /src/lintian && \
    wget --tries=3 -nv -O- "https://deb.debian.org/debian/pool/main/l/lintian/lintian_${VERSION}.tar.xz" 2>/tmp/lintian-wget.err | \
    tar -xJf - -C /src/lintian --strip-components=1 || { cat /tmp/lintian-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
