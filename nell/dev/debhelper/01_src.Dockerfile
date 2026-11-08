FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=14.5

RUN mkdir -p /src/debhelper && \
    wget -qO- "https://deb.debian.org/debian/pool/main/d/debhelper/debhelper_${VERSION}.tar.xz" | \
    tar -xJf - -C /src/debhelper --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
