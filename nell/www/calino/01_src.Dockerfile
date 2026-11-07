FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.42.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/Ivan-Malinovski/calino.git /src/calino

FROM scratch
COPY --from=build /src/ /src/
