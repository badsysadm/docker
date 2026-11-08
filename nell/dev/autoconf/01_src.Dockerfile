FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.73

RUN mkdir -p /src/autoconf && \
    wget -qO- "https://ftp.gnu.org/gnu/autoconf/autoconf-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/autoconf --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
