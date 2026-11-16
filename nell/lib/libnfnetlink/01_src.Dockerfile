FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.0.2

RUN install -d /src/libnfnetlink && \
    wget --tries=3 -nv -O- "https://www.netfilter.org/pub/libnfnetlink/libnfnetlink-${VERSION}.tar.bz2" 2>/tmp/libnfnetlink-wget.err | \
    tar -xjf - -C /src/libnfnetlink --strip-components=1 || { cat /tmp/libnfnetlink-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
