FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=8.0.8

RUN git clone -q --single-branch --branch "suricata-${VERSION}" --depth 1 \
    https://github.com/OISF/suricata.git /src/suricata

FROM scratch
COPY --from=build /src/ /src/
