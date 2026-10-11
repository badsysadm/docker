FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.20.3

RUN mkdir -p /src/shadow && \
    wget -qO- "https://github.com/shadow-maint/shadow/releases/download/${VERSION}/shadow-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/shadow --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
