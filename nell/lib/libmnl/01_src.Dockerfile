FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.0.5

RUN install -d /src/libmnl && \
    wget --tries=3 -nv -O- "https://www.netfilter.org/pub/libmnl/libmnl-${VERSION}.tar.bz2" 2>/tmp/libmnl-wget.err | \
    tar -xjf - -C /src/libmnl --strip-components=1 || { cat /tmp/libmnl-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
