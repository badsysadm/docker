FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.0.2

RUN install -d /src/libnetfilter_log && \
    wget --tries=3 -nv -O- "https://www.netfilter.org/pub/libnetfilter_log/libnetfilter_log-${VERSION}.tar.bz2" 2>/tmp/libnetfilter_log-wget.err | \
    tar -xjf - -C /src/libnetfilter_log --strip-components=1 || { cat /tmp/libnetfilter_log-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
