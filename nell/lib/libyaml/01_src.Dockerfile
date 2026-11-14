FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.2.5

RUN git clone -q --single-branch --branch "0.2.5" --depth 1 \
    https://github.com/yaml/libyaml.git /src/libyaml

FROM scratch
COPY --from=build /src/ /src/
