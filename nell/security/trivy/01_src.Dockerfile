FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.76.2

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/aquasecurity/trivy.git /src/trivy

FROM scratch
COPY --from=build /src/ /src/
