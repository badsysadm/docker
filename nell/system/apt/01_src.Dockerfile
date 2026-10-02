FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.3.3
ARG OPENSSL_VERSION=3.4.1

RUN git clone -q --single-branch --branch ${VERSION} --depth 1 https://salsa.debian.org/apt-team/apt.git /src/apt
RUN git clone -q --single-branch --branch "openssl-${OPENSSL_VERSION}" --depth 1 https://github.com/openssl/openssl.git /src/openssl

FROM scratch
COPY --from=build /src/ /src
