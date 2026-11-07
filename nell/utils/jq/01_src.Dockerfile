FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.8.2

RUN mkdir -p /src/jq && \
    wget -qO- "https://github.com/jqlang/jq/releases/download/jq-${VERSION}/jq-${VERSION}.tar.gz" \
    | tar -xzf - -C /src/jq --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
