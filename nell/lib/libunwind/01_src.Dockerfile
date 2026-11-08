FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.8.3

RUN mkdir -p /src/libunwind && \
    wget -qO- "https://github.com/libunwind/libunwind/releases/download/v${VERSION}/libunwind-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/libunwind --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
