FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.0.5

RUN install -d /src/libnetfilter_queue && \
    wget --tries=3 -nv -O- "https://www.netfilter.org/pub/libnetfilter_queue/libnetfilter_queue-${VERSION}.tar.bz2" 2>/tmp/libnetfilter_queue-wget.err | \
    tar -xjf - -C /src/libnetfilter_queue --strip-components=1 || { cat /tmp/libnetfilter_queue-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
