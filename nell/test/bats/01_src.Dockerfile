FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.14.0
ARG SUPPORT_VERSION=0.3.0
ARG ASSERT_VERSION=2.2.4
ARG DETIK_VERSION=1.4.0
ARG FILE_VERSION=0.4.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/bats-core/bats-core.git /src/bats-core && \
    git clone -q --single-branch --branch "v${SUPPORT_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-support.git /src/bats-support && \
    git clone -q --single-branch --branch "v${ASSERT_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-assert.git /src/bats-assert && \
    git clone -q --single-branch --branch "v${DETIK_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-detik.git /src/bats-detik && \
    git clone -q --single-branch --branch "v${FILE_VERSION}" --depth 1 \
    https://github.com/bats-core/bats-file.git /src/bats-file

FROM scratch
COPY --from=build /src/ /src/
