FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3.1

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/koutheir/binary-security-check.git /src/binary-security-check

FROM scratch
COPY --from=build /src/ /src/
