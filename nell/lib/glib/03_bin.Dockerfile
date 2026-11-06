ARG VERSION=2.84.4

FROM oci.badsysadm.local:80/dep/lib/glib:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/glib

RUN meson setup build \
        --prefix=/usr \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --buildtype=release \
        -Ddefault_library=static \
        -Db_staticpic=true \
        -Dprefer_static=true \
        -Dselinux=disabled \
        -Dlibmount=disabled \
        -Dsysprof=disabled \
        -Dlibelf=disabled \
        -Dintrospection=disabled \
        -Dnls=disabled \
        -Ddocumentation=false \
        -Dman-pages=disabled \
        -Dtests=false \
        -Dinstalled_tests=false \
        -Ddtrace=disabled \
        -Dsystemtap=disabled

RUN ninja -C build
RUN DESTDIR=/src/target meson install -C build

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info \
        /src/target/usr/share/locale \
        /src/target/usr/share/gtk-doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="glib"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GLib static libraries and build tools"

COPY --from=build /src/target/ /target/
