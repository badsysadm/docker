FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.12

RUN mkdir -p /src/grep && \
    wget -qO- "https://ftp.gnu.org/gnu/grep/grep-${VERSION}.tar.xz" \
    | tar -xJf - -C /src/grep --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
