FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.10.3

RUN mkdir -p /src/cracklib /src/target && \
    wget -qO- "https://github.com/cracklib/cracklib/releases/download/v${VERSION}/cracklib-${VERSION}.tar.bz2" | \
    tar -xjf - -C /src/cracklib --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
