ARG VERSION=6.6

FROM oci.badsysadm.local:80/dep/lib/ncurses:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/ncurses

# Install shared libraries first, then overwrite programs with the
# statically linked (ncurses) variants from the normal build model.
RUN set -e; \
    for model in shared normal; do \
        mkdir -p "/src/ncurses-build-${model}"; \
        cd "/src/ncurses-build-${model}"; \
        if [ "${model}" = shared ]; then \
            model_flags="--with-shared --without-normal"; \
        else \
            model_flags="--without-shared --with-normal"; \
        fi; \
        cf_cv_ar_flags=-crD /src/ncurses/configure \
            --prefix=/usr \
            --sysconfdir=/etc \
            --bindir=/usr/bin \
            --libdir=/usr/lib \
            --without-manpages \
            --without-tests \
            --without-debug \
            --enable-widec \
            --enable-pc-files \
            --with-pkg-config-libdir=/usr/lib/pkgconfig \
            --enable-ext-colors \
            --enable-ext-mouse \
            ${model_flags}; \
        make -j$(nproc); \
        make install DESTDIR=/src/target; \
    done

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="ncurses"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="ncurses libraries and terminal utilities"
COPY --from=build /src/target/ /target/
