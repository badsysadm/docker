FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.24

RUN mkdir -p /src/target && \
    git clone \
        --single-branch \
        --branch v${VERSION} \
        --depth 1 \
        https://github.com/berke/wipe.git \
        /src/wipe

FROM scratch
COPY --from=build /src/ /src
