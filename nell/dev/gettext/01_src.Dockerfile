FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.0

RUN mkdir -p /src/gettext && \
    wget -qO- "https://ftp.gnu.org/gnu/gettext/gettext-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/gettext --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
