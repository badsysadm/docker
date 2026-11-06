FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.2.1

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/hashicorp/vault.git /src/vault
RUN mkdir -p /sha256 \
    && find /src/vault -path /src/vault/.git -prune -o -type f -print0 \
       | sort -z | xargs -0 sha256sum > /sha256/01_source.sha256

FROM scratch
COPY --from=build /src/ /src/
COPY --from=build /sha256/ /sha256/
