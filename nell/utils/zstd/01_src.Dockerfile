FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.5.7

RUN mkdir -p /src/zstd && \
    wget -qO- \
        "https://github.com/facebook/zstd/releases/download/v${VERSION}/zstd-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/zstd --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
