FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.69

RUN mkdir -p /src/quilt && \
    wget -qO- "https://deb.debian.org/debian/pool/main/q/quilt/quilt_${VERSION}.orig.tar.gz" | \
    tar -xzf - -C /src/quilt --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
