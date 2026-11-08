FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.4.1

RUN mkdir -p /src/make && \
    wget -qO- "https://ftp.gnu.org/gnu/make/make-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/make --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
