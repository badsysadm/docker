ARG VERSION=2.10.0

FROM oci.badsysadm.local:80/dep/usr/kbd:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/kbd

RUN ./configure \
    --prefix=/usr \
    --disable-vlock \
    --disable-nls \
    --disable-tests \
    --disable-compress

RUN touch aclocal.m4 && \
    touch configure config.h.in && \
    find . -type f -name "Makefile.in" -exec touch {} + && \
    ./config.status

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="kbd"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux keyboard and console utilities"
COPY --from=build /src/target/ /target/
