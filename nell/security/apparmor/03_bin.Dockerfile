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

RUN make -C parser -j$(nproc) \
      CFLAGS='-O2 -pipe' \
      LDFLAGS='-static-libgcc -static-libstdc++'
RUN make -C parser install DESTDIR=/src/target DISTRO=debian
RUN make -C parser install-systemd DESTDIR=/src/target

RUN LDFLAGS='-static-libgcc -static-libstdc++' \
    make -C binutils -j$(nproc) \
      CFLAGS='-O2 -pipe'
RUN make -C binutils install DESTDIR=/src/target

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
