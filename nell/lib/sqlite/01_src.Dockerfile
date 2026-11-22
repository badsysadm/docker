FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.54.1

RUN mkdir -p /src/sqlite && \
    wget --tries=3 -nv -O- "https://www.sqlite.org/2026/sqlite-autoconf-$(echo ${VERSION} | awk -F. '{printf "%d%02d%02d00", $1, $2, $3}').tar.gz" 2>/tmp/sqlite-wget.err | \
    tar -xzf - -C /src/sqlite --strip-components=1 || { cat /tmp/sqlite-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
