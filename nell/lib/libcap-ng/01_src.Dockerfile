FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.8.5

RUN git clone -q --single-branch --branch "v0.8.5" --depth 1 \
    https://github.com/stevegrubb/libcap-ng.git /src/libcap-ng

FROM scratch
COPY --from=build /src/ /src/
