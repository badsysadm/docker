FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.8.3

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/Cyan4973/xxHash.git /src/xxhash

FROM scratch
COPY --from=build /src/ /src/
