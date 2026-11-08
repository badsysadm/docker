FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.8.1

RUN mkdir -p /src/patch && \
    wget -qO- "https://ftp.gnu.org/gnu/patch/patch-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/patch --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
