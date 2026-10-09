FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.10

RUN mkdir -p /src/target && \
    git clone \
        --single-branch \
        --branch v${VERSION} \
        --depth 1 \
        https://github.com/ecki/net-tools.git \
        /src/net-tools

FROM scratch
COPY --from=build /src/ /src
