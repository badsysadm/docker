FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.8.3

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/libunwind/libunwind.git /src/libunwind

FROM scratch
COPY --from=build /src/ /src/
