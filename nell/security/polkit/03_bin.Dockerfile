ARG VERSION=127

FROM oci.badsysadm.local:80/dep/security/polkit:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/polkit

RUN gcc -O2 -fPIC \
        -I/usr/share/duktape \
        -c /usr/share/duktape/duktape.c \
        -o /usr/lib/x86_64-linux-gnu/duktape.o && \
    ar rcs \
        /usr/lib/x86_64-linux-gnu/libduktape.a \
        /usr/lib/x86_64-linux-gnu/duktape.o

# polkit 127 still builds po targets with -Dgettext=false.
RUN sed -i "/subdir('po')/d" meson.build && \
    sed -i \
        -e 's/i18n\.merge_file(/configure_file(/' \
        -e '/po_dir: po_dir,/d' \
        -e '/data_dirs: its_dir,/d' \
        -e "/output: '@BASENAME@',/a\\  copy: true," \
        actions/meson.build

RUN meson setup build \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --buildtype=release \
        -Dprefer_static=true \
        -Dsession_tracking=logind \
        -Dauthfw=pam \
        -Dos_type=debian \
        -Dsystemdsystemunitdir=/usr/lib/systemd/system \
        -Dintrospection=false \
        -Dgtk_doc=false \
        -Dman=false \
        -Dgettext=false \
        -Dexamples=false \
        -Dtests=false

RUN ninja -C build
RUN DESTDIR=/src/target meson install -C build

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info \
        /src/target/usr/share/locale \
        /src/target/usr/share/gettext

FROM scratch AS bundle
LABEL org.opencontainers.image.title="polkit"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="authorization framework"

COPY --from=build /src/target/ /target/
