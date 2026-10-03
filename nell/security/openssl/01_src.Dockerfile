FROM oci.badsysadm.local:80/get/source:latest AS build

ARG VERSION=3.6.5

RUN BRANCH="openssl-${VERSION}" && \
    git clone --single-branch --branch "${BRANCH}" --depth 1 https://github.com/openssl/openssl.git /src/openssl

FROM scratch
COPY --from=build /src/ /src
