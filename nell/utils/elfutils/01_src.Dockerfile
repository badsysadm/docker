FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.196

RUN mkdir -p /src/elfutils && \
    wget -qO- https://sourceware.org/pub/elfutils/${VERSION}/elfutils-${VERSION}.tar.bz2 | \
        tar -xjf - -C /src/elfutils --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
