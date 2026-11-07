ARG VERSION=2.56.0

FROM oci.badsysadm.local:80/dep/dev/git:${VERSION} AS build
ARG VERSION

WORKDIR /src/git

RUN make -j$(nproc) \
    prefix=/usr \
    NO_RUST=YesPlease \
    NO_GETTEXT=YesPlease \
    NO_TCLTK=YesPlease \
    NO_PERL=YesPlease \
    NO_PYTHON=YesPlease \
    NO_EXPAT=YesPlease \
    NO_GITWEB=YesPlease \
    NO_OPENSSL=YesPlease \
    SKIP_DASHED_BUILT_INS=YesPlease \
    INSTALL_SYMLINKS=YesPlease \
    NO_INSTALL_HARDLINKS=YesPlease \
    CFLAGS="-Os -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc -Wl,--gc-sections" \
    CURL_LDFLAGS="-Wl,-Bstatic $(pkg-config --static --libs libcurl) -Wl,-Bdynamic" \
    LIBS='$(filter-out %.o,$(GITLIBS)) -Wl,-Bstatic $(EXTLIBS) -Wl,-Bdynamic'

RUN make install \
    prefix=/usr \
    DESTDIR=/src/target \
    NO_RUST=YesPlease \
    NO_GETTEXT=YesPlease \
    NO_TCLTK=YesPlease \
    NO_PERL=YesPlease \
    NO_PYTHON=YesPlease \
    NO_EXPAT=YesPlease \
    NO_GITWEB=YesPlease \
    NO_OPENSSL=YesPlease \
    SKIP_DASHED_BUILT_INS=YesPlease \
    INSTALL_SYMLINKS=YesPlease \
    NO_INSTALL_HARDLINKS=YesPlease \
    CFLAGS="-Os -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc -Wl,--gc-sections" \
    CURL_LDFLAGS="-Wl,-Bstatic $(pkg-config --static --libs libcurl) -Wl,-Bdynamic" \
    LIBS='$(filter-out %.o,$(GITLIBS)) -Wl,-Bstatic $(EXTLIBS) -Wl,-Bdynamic' \
    INSTALL_STRIP=-s

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/locale

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="git"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Git version control system with HTTPS support"
COPY --from=build /src/target/ /target/
