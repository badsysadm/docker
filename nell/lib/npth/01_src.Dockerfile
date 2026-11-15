FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.8

RUN git clone -q --single-branch --branch "npth-${VERSION}" --depth 1 \
    https://github.com/gpg/npth.git /src/npth

FROM scratch
COPY --from=build /src/ /src/
