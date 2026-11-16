FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.2.0

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://github.com/slimm609/checksec.git /src/checksec

FROM scratch
COPY --from=build /src/ /src/
