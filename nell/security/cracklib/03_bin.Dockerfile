ARG VERSION=2.10.3

FROM oci.badsysadm.local:80/dep/security/cracklib:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/cracklib

RUN touch aclocal.m4 && \
    touch configure config.h.in && \
    find . -type f -name 'Makefile.in' -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --enable-shared \
    --enable-static \
    --without-python \
    --disable-nls \
    --with-default-dict=/usr/share/cracklib/pw_dict

RUN make -j$(nproc) \
    LIBS="/usr/lib/x86_64-linux-gnu/libz.a"
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/locale && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
LABEL org.opencontainers.image.title="cracklib"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="CrackLib password checker and dictionary utilities"
COPY --from=build /src/target/ /target/
