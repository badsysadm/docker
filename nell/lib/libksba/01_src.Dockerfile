FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.6.7

RUN git clone -q --single-branch --branch "libksba-${VERSION}" --depth 1 \
    https://github.com/gpg/libksba.git /src/libksba

FROM scratch
COPY --from=build /src/ /src/
