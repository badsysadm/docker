FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.12.4

RUN git clone -q --single-branch --branch "libgcrypt-${VERSION}" --depth 1 \
    https://github.com/gpg/libgcrypt.git /src/libgcrypt

FROM scratch
COPY --from=build /src/ /src/
