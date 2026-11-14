FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/libnet/libnet.git /src/libnet

FROM scratch
COPY --from=build /src/ /src/
