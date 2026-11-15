ARG VERSION=1.22.11

FROM oci.badsysadm.local:80/dep/system/dpkg:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/dpkg

COPY debian/patches /src/patches/
RUN git apply /src/patches/_pax.patch
RUN echo "${VERSION}" > .dist-version && \
    git rev-parse HEAD > .dist-vcs-id

RUN autoreconf -f -i

RUN CFLAGS="-O2 -fPIC" \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib" \
    LIBS="-Wl,-Bstatic -Wl,--start-group /usr/local/lib/libmd.a /usr/local/lib/liblzma.a /usr/local/lib/libzstd.a /usr/local/lib/libbz2.a /usr/local/lib/libz.a -Wl,--end-group -Wl,-Bdynamic" \
    ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-shared \
    --with-libz=static \
    --with-libz-ng=no \
    --with-liblzma=static \
    --with-libzstd=static \
    --with-libbz2=static \
    --without-libselinux \
    --enable-static \
    --disable-dselect \
    --disable-start-stop-daemon \
    --enable-update-alternatives \
    --disable-devel-docs \
    --disable-nls

RUN make -j$(nproc) SUBDIRS="lib src utils scripts" MAKEOVERRIDES=
RUN make install DESTDIR=/src/target SUBDIRS="lib src utils scripts" MAKEOVERRIDES=

# Bundle all dpkg-dev Perl programs with their modules and Perl runtime.
# The Dpkg modules are produced by upstream make install; include every
# module explicitly because vendor and source-format modules load dynamically.
RUN set -- -M Dpkg; \
    for file in $(find /src/target/usr/share/perl5/Dpkg -type f -name '*.pm' | LC_ALL=C sort); do \
        module="${file#/src/target/usr/share/perl5/}"; \
        module="${module%.pm}"; \
        module="$(printf '%s' "${module}" | sed 's@/@::@g')"; \
        set -- "$@" -M "${module}"; \
    done; \
    for name in \
        dpkg-architecture dpkg-buildapi dpkg-buildflags dpkg-buildpackage \
        dpkg-buildtree dpkg-checkbuilddeps dpkg-distaddfile dpkg-genbuildinfo \
        dpkg-genchanges dpkg-gencontrol dpkg-gensymbols dpkg-mergechangelogs \
        dpkg-name dpkg-parsechangelog dpkg-scanpackages dpkg-scansources \
        dpkg-shlibdeps dpkg-source dpkg-vendor; do \
        TZ=UTC PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 \
        faketime -f '2020-01-01 00:00:00' \
        pp -B -I /src/target/usr/share/perl5 "$@" \
            -M Algorithm::Merge -M File::FcntlLock -M Locale::gettext \
            -o "/src/target/usr/bin/${name}.par" \
            "/src/target/usr/bin/${name}" && \
        mv "/src/target/usr/bin/${name}.par" "/src/target/usr/bin/${name}" || exit 1; \
    done

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc
RUN find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
LABEL org.opencontainers.image.title="dpkg"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Low-level package manager"
COPY --from=build /src/target/ /target/
