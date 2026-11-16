FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.11.1

RUN git clone -q --single-branch --branch "libssh2-${VERSION}" --depth 1 \
    https://github.com/libssh2/libssh2.git /src/libssh2

FROM scratch
COPY --from=build /src/ /src/
