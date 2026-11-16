FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.80

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/al13n321/nnd.git /src/nnd

FROM scratch
COPY --from=build /src/ /src/
