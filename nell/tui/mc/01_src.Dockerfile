FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.8.33

RUN mkdir -p /src/mc && \
    wget -qO- "https://ftp.osuosl.org/pub/midnightcommander/mc-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/mc --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
