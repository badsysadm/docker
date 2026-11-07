FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=9.2

RUN mkdir -p /src/nano && \
    wget -qO- "https://ftp.gnu.org/gnu/nano/nano-${VERSION}.tar.xz" \
    | tar -xJf - -C /src/nano --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
