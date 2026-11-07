FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.23.1

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/Luzifer/ots.git /src/ots

FROM scratch
COPY --from=build /src/ /src/
