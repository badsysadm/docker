ARG VERSION=2.14

FROM oci.badsysadm.local:80/dep/system/grub:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/efivar

RUN make ENABLE_DOCS=0 PREFIX=/usr/local LIBDIR=/usr/local/lib -j$(nproc)
RUN make -C src TOPDIR=/src/efivar ENABLE_DOCS=0 PREFIX=/usr/local LIBDIR=/usr/local/lib \
    libefivar.a libefiboot.a
RUN make ENABLE_DOCS=0 PREFIX=/usr/local LIBDIR=/usr/local/lib install
RUN install -Dm644 src/libefivar.a /usr/local/lib/libefivar.a && \
    install -Dm644 src/libefiboot.a /usr/local/lib/libefiboot.a

WORKDIR /src/lvm2

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +
RUN ./configure \
    --prefix=/usr/local \
    --libdir=/usr/local/lib \
    --enable-static_link \
    --enable-pkgconfig \
    --disable-udev_sync \
    --disable-udev_rules \
    --disable-selinux \
    --disable-readline \
    --disable-editline \
    --disable-nls \
    --with-thin=none \
    --with-cache=none \
    --with-vdo=none \
    --with-writecache=none \
    --with-integrity=none

RUN make -C libdm -j$(nproc)
RUN make -C libdm install

WORKDIR /src/grub

RUN python3 gentpl.py Makefile.util.def Makefile.utilgcry.def > Makefile.util.am && \
    python3 gentpl.py grub-core/Makefile.core.def grub-core/Makefile.gcry.def > grub-core/Makefile.core.am && \
    find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN mkdir -p /src/grub-build-efi /src/grub-build-bios

WORKDIR /src/grub-build-efi

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib" \
    /src/grub/configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --target=x86_64 \
        --with-platform=efi \
        --disable-nls \
        --disable-efiemu \
        --disable-werror \
        --disable-grub-mount \
        --disable-grub-mkfont \
        --disable-grub-themes \
        --enable-device-mapper \
        --enable-liblzma \
        --disable-libzfs \
        --enable-grub-protect

RUN sed -i \
    -e 's|^LIBDEVMAPPER =.*|LIBDEVMAPPER = -Wl,--start-group /usr/local/lib/libdevmapper.a -Wl,--end-group -lm -lpthread -ldl|' \
    -e 's|^EFIVAR_LIBS =.*|EFIVAR_LIBS = -Wl,--start-group /usr/local/lib/libefiboot.a /usr/local/lib/libefivar.a -Wl,--end-group -ldl|' \
    -e 's|^LIBLZMA =.*|LIBLZMA = /usr/lib/x86_64-linux-gnu/liblzma.a|' \
    -e 's|^LIBTASN1 =.*|LIBTASN1 = /usr/lib/x86_64-linux-gnu/libtasn1.a|' \
    Makefile

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target/efi

WORKDIR /src/grub-build-bios

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib" \
    /src/grub/configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --target=i386 \
        --with-platform=pc \
        --disable-nls \
        --disable-efiemu \
        --disable-werror \
        --disable-grub-mount \
        --disable-grub-mkfont \
        --disable-grub-themes \
        --enable-device-mapper \
        --enable-liblzma \
        --disable-libzfs \
        --enable-grub-protect

RUN sed -i \
    -e 's|^LIBDEVMAPPER =.*|LIBDEVMAPPER = -Wl,--start-group /usr/local/lib/libdevmapper.a -Wl,--end-group -lm -lpthread -ldl|' \
    -e 's|^LIBLZMA =.*|LIBLZMA = /usr/lib/x86_64-linux-gnu/liblzma.a|' \
    -e 's|^LIBTASN1 =.*|LIBTASN1 = /usr/lib/x86_64-linux-gnu/libtasn1.a|' \
    Makefile

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target/bios

RUN rm -rf \
    /src/target/efi/usr/share/doc \
    /src/target/efi/usr/share/info \
    /src/target/efi/usr/share/man \
    /src/target/bios/usr/share/doc \
    /src/target/bios/usr/share/info \
    /src/target/bios/usr/share/man

FROM scratch AS bundle
LABEL org.opencontainers.image.title="grub"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GRUB x86_64 EFI and i386 PC bundle"

COPY --from=build /src/target/ /target/
