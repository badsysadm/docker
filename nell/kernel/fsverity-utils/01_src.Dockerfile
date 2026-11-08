FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.7

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/ebiggers/fsverity-utils.git /src/fsverity-utils

FROM scratch
COPY --from=build /src/ /src/
