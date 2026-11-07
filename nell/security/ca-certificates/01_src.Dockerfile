FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=20260816

RUN mkdir -p /src/ca-certificates && \
    wget -qO- \
        "https://deb.debian.org/debian/pool/main/c/ca-certificates/ca-certificates_${VERSION}.tar.xz" | \
    tar -xJf - -C /src/ca-certificates --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
