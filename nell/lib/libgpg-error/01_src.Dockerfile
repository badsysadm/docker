FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.51

RUN git clone -q --single-branch --branch "libgpg-error-${VERSION}" --depth 1 \
    https://github.com/gpg/libgpg-error.git /src/libgpg-error

FROM scratch
COPY --from=build /src/ /src/
