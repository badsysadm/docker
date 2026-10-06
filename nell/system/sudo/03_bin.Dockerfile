ARG VERSION=1.9.17p2

FROM oci.badsysadm.local:80/dep/system/sudo:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/sudo

RUN LDFLAGS="-L/usr/lib64 -Wl,--as-needed" \
    SUDO_LIBS="-Wl,-Bstatic -Wl,--start-group -laudit -lcap-ng -Wl,--end-group -Wl,-Bdynamic" \
    SUDOERS_LIBS="-Wl,-Bstatic -Wl,--start-group -laudit -lcap-ng -Wl,--end-group -Wl,-Bdynamic" \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --with-rundir=/run/sudo \
        --with-pam \
        --with-pam-login \
        --with-linux-audit \
        --with-logging=syslog \
        --with-logfac=authpriv \
        --enable-static-sudoers \
        --disable-shared-libutil \
        --enable-zlib=static \
        --disable-log-server \
        --disable-log-client \
        --disable-openssl \
        --disable-nls \
        --disable-rpath

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/info \
    /src/target/usr/share/man

FROM scratch AS bundle
LABEL org.opencontainers.image.title="sudo"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="sudo privilege management utilities"

COPY --from=build /src/target/ /target/
