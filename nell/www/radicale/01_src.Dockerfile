FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.9.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/Kozea/Radicale.git /src/radicale

FROM scratch
COPY --from=build /src/ /src/
