FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.84.4

RUN mkdir -p /src/glib && \
    wget -qO- https://download.gnome.org/sources/glib/2.84/glib-${VERSION}.tar.xz | \
        tar -xJf - -C /src/glib --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
