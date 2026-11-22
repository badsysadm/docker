FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.54.1

RUN git clone -q --single-branch --branch "version-${VERSION}" --depth 1 \
    https://github.com/sqlite/sqlite.git /src/sqlite

FROM scratch
COPY --from=build /src/ /src/
