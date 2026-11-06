ARG VERSION=1.16.2

FROM oci.badsysadm.local:80/dep/system/dbus:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/dbus

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
    -Dducktype_docs=disabled \
    -Dxml_docs=disabled \
    -Dintrusive_tests=false \
    -Dinstalled_tests=false \
    -Dmodular_tests=disabled \
    -Dvalgrind=disabled \
    -Dsystemd=enabled \
    -Dapparmor=enabled \
    -Dselinux=disabled \
    -Depoll=enabled \
    -Dinotify=enabled \
    -Dstats=true \
    -Dverbose_mode=false \
    -Dx11_autolaunch=disabled \
    -Dwindows_output_debug_string=false

RUN ninja -C build
RUN DESTDIR=/src/target ninja -C build/ install

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="dbus"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Message bus daemon"

COPY --from=build /src/target/ /target/
