ARG VERSION=4.1.8
FROM oci.badsysadm.local:80/dep/security/apparmor:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION
ARG SOURCE_DATE_EPOCH=0
WORKDIR /src/apparmor

# Build the in-tree C library first.
RUN cd libraries/libapparmor && \
    sh ./autogen.sh && \
    ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
      --enable-static --enable-shared --disable-man-pages \
      --without-python --without-perl --without-ruby && \
    make -j$(nproc) && \
    make install DESTDIR=/src/target

# Build binaries without documentation and translation targets.
RUN make -C parser -j$(nproc) arch \
      CFLAGS='-O2 -pipe' \
      LDFLAGS='-static-libgcc -static-libstdc++' && \
    make -C parser install-arch DESTDIR=/src/target DISTRO=debian

RUN LDFLAGS='-static-libgcc -static-libstdc++' \
    make -C binutils -j$(nproc) arch \
      CFLAGS='-O2 -pipe' && \
    make -C binutils install-arch DESTDIR=/src/target

# Install runtime configuration and systemd integration directly.
RUN install -d /src/target/etc/apparmor \
      /src/target/lib/apparmor \
      /src/target/usr/lib/systemd/system \
      /src/target/usr/sbin && \
    install -m 644 parser/parser.conf /src/target/etc/apparmor/parser.conf && \
    install -m 755 parser/rc.apparmor.functions parser/profile-load \
      parser/apparmor.systemd /src/target/lib/apparmor/ && \
    install -m 644 parser/apparmor.service \
      /src/target/usr/lib/systemd/system/apparmor.service && \
    install -m 755 parser/aa-teardown /src/target/usr/sbin/ && \
    ln -s aa-status /src/target/usr/sbin/apparmor_status

RUN make -C profiles install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/doc \
           /src/target/usr/share/man \
           /src/target/usr/share/info \
           /src/target/usr/share/locale \
           /src/target/usr/share/gtk-doc && \
    find /src/target -type f \( -name '*.la' -o -name 'README*' \) -delete

FROM scratch AS bundle
LABEL org.opencontainers.image.title="apparmor"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="AppArmor userspace bundle"
COPY --from=build /src/target/ /target/
