FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3.1

RUN mkdir -p /src/zlib && \
    wget -qO- "https://zlib.net/fossils/zlib-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/zlib --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
