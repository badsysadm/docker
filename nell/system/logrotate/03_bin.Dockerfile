ARG VERSION=3.22.0

FROM oci.badsysadm.local:80/dep/system/logrotate:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/logrotate

RUN mkdir -p /src/static-libs && \
    cp \
        /usr/lib/x86_64-linux-gnu/libacl.a \
        /usr/lib/x86_64-linux-gnu/libpopt.a \
        /src/static-libs/

RUN LDFLAGS="-static-libgcc -L/src/static-libs -Wl,--as-needed" \
    ./configure \
        --prefix=/usr \
        --sbindir=/usr/sbin \
        --with-acl=yes \
        --with-selinux=no \
        --with-state-file-path=/var/lib/logrotate/status

RUN make -j$(nproc) logrotate \
        LDFLAGS="-static-libgcc -L/src/static-libs -Wl,--as-needed" \
        LIBS="-Wl,-Bstatic -lacl -lpopt -Wl,-Bdynamic"

RUN make install DESTDIR=/src/target

RUN install -Dm644 \
        examples/logrotate.service \
        /src/target/usr/lib/systemd/system/logrotate.service && \
    install -Dm644 \
        examples/logrotate.timer \
        /src/target/usr/lib/systemd/system/logrotate.timer && \
    install -d -m755 \
        /src/target/etc/logrotate.d \
        /src/target/var/lib/logrotate

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info \
        /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="logrotate"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="log file rotation utility"

COPY --from=build /src/target/ /target/
