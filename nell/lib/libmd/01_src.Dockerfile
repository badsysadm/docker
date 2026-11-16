FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3.0

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://github.com/guillemj/libmd.git /src/libmd

FROM scratch
COPY --from=build /src/ /src/
