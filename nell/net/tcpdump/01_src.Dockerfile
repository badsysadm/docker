FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.99.7

RUN git clone -q --single-branch --branch "tcpdump-${VERSION}" --depth 1 \
    https://github.com/the-tcpdump-group/tcpdump.git /src/tcpdump

FROM scratch
COPY --from=build /src/ /src/
