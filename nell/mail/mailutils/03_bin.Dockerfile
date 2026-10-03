ARG VERSION=3.21

FROM oci.badsysadm.local:80/dep/mail/mailutils:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION
ARG SOURCE_DATE_EPOCH=0

WORKDIR /src/mailutils

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH}" && \
    export PKG_CONFIG="pkg-config --static" && \
    export LDFLAGS="-static-libgcc -Wl,-Bstatic" && \
    export LIBS="-Wl,-Bdynamic" && \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --enable-static \
        --disable-shared \
        --disable-pam \
        --without-python \
        --without-guile \
        --with-gdbm

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="mailutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Mailutils bundle"

COPY --from=build /src/target/ /target/
