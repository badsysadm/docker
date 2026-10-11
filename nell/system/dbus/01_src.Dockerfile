FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.16.2

RUN git clone --single-branch --branch dbus-${VERSION} --depth 1 \
    https://gitlab.freedesktop.org/dbus/dbus.git /src/dbus

FROM scratch
COPY --from=build /src/ /src/
