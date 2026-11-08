FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.12.1

RUN git clone --depth 1 --branch "${VERSION}" \
    https://github.com/mesonbuild/meson.git /src/meson

FROM scratch
COPY --from=build /src/ /src/
