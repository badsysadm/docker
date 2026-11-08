FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.14.0
ARG BATS_SUPPORT_VERSION=0.3.0
ARG BATS_ASSERT_VERSION=2.2.4
ARG BATS_DETIK_VERSION=1.4.0
ARG BATS_FILE_VERSION=0.4.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/bats-core/bats-core.git /src/bats-core

RUN git clone -q --single-branch --branch "v${BATS_SUPPORT_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-support.git /src/bats-support

RUN git clone -q --single-branch --branch "v${BATS_ASSERT_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-assert.git /src/bats-assert

RUN git clone -q --single-branch --branch "v${BATS_DETIK_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-detik.git /src/bats-detik

RUN git clone -q --single-branch --branch "v${BATS_FILE_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-file.git /src/bats-file

FROM scratch
COPY --from=build /src/ /src/
