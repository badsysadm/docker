FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.0.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/sharkdp/hyperfine.git /src/hyperfine

FROM scratch
COPY --from=build /src/ /src/
