FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.8.1.3

RUN mkdir -p /src/socat && \
    wget -qO- "http://www.dest-unreach.org/socat/download/socat-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/socat --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
