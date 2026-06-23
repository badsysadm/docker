FROM mirror.gcr.io/library/debian:trixie
ARG DBUS_VERSION=dbus-1.16.2

RUN  apt-get update && apt-get install -y -qq --no-install-recommends \
     build-essential git pkg-config ca-certificates \
     meson ninja-build \
     libsystemd-dev libcap-dev libexpat1-dev
RUN git clone --single-branch --branch ${DBUS_VERSION} --depth 1 https://gitlab.freedesktop.org/dbus/dbus.git /src/dbus
WORKDIR /src/dbus

#ARG LDFLAGS="-lcap"
ARG LDFLAGS="-Wl,-Bstatic -lcap -lsystemd -Wl,-Bdynamic"
RUN meson setup build \
    --prefix=/usr \
    --buildtype=release \
    --default-library=static \
    --wrap-mode=nodownload \
    -Dprefer_static=true \
    -Dauto_features=disabled \
    -Dmessage_bus=true \
    -Dtools=true \
    -Ddoxygen_docs=disabled \
    -Dselinux=disabled \
    -Ddoxygen_docs=disabled \
    -Dxml_docs=disabled \
    -Dsystemd=enabled
RUN ninja -C build
RUN DESTDIR=debian/tmp ninja -C build/ install
