ARG VERSION=1.0

FROM oci.badsysadm.local:80/dep/dev/gettext:${VERSION} AS build
ARG VERSION

WORKDIR /src/gettext

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --disable-nls \
    --disable-java \
    --disable-csharp \
    --disable-openmp \
    --disable-libtextstyle \
    --without-emacs \
    --with-included-libunistring \
    --enable-static \
    --enable-shared \
    LDFLAGS="-static-libgcc"

# Keep both libtool library formats, but link the tools to static archives.
RUN for program in \
        msgattrib msgcat msgcmp msgcomm msgconv msgen msgexec \
        msgfilter msgfmt msggrep msginit msgmerge msgpre msgunfmt \
        msguniq recode_sr_latin xgettext; do \
        printf 'override %s_LDFLAGS += -static-libtool-libs\n' \
            "$program"; \
    done >> gettext-tools/src/Makefile

RUN make -j$(nproc) \
    MAKEINFO=true \
    man_MANS= \
    notrans_man_MANS= \
    man_HTML=
RUN make install DESTDIR=/src/target \
    MAKEINFO=true \
    man_MANS= \
    notrans_man_MANS= \
    man_HTML=

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/locale && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="gettext"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Gettext internationalization tools"
COPY --from=build /src/target/ /target/
