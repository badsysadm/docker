FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.14.1

RUN git clone -q --single-branch --branch "v2.14.1" --depth 1 \
    https://github.com/akheron/jansson.git /src/jansson

FROM scratch
COPY --from=build /src/ /src/
