FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.1.8
RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://gitlab.com/apparmor/apparmor.git /src/apparmor
FROM scratch
COPY --from=build /src/ /src/
