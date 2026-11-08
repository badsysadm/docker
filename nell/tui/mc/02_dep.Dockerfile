ARG VERSION=4.8.33
ARG GLIB_VERSION=2.84.4
ARG NCURSES_VERSION=6.6
ARG ZLIB_VERSION=1.3.1

FROM oci.badsysadm.local:80/src/tui/mc:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/glib:${GLIB_VERSION} AS glib_image
FROM oci.badsysadm.local:80/bin/lib/ncurses:${NCURSES_VERSION} AS ncurses_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=glib_image /target/usr/include/glib-2.0/ /usr/local/include/glib-2.0/
COPY --from=glib_image /target/usr/lib/ /usr/local/lib/
RUN sed -i \
    -e 's|^prefix=.*|prefix=/usr/local|' \
    -e 's|^libdir=.*|libdir=/usr/local/lib|' \
    -e 's|^includedir=.*|includedir=/usr/local/include|' \
    /usr/local/lib/pkgconfig/glib-2.0.pc \
    /usr/local/lib/pkgconfig/gmodule-2.0.pc \
    /usr/local/lib/pkgconfig/gmodule-no-export-2.0.pc

COPY --from=ncurses_image /target/usr/include/ /usr/local/include/
COPY --from=ncurses_image /target/usr/lib/ /usr/local/lib/
RUN mkdir -p /usr/local/include/ncursesw && \
    ln -s ../curses.h /usr/local/include/ncursesw/curses.h && \
    ln -s ../term.h /usr/local/include/ncursesw/term.h

RUN cp /usr/lib/libe2p.a \
       /usr/lib/libpcre2-8.a \
       /usr/local/lib/

COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/libz.a /usr/local/lib/libz.a

COPY --from=src_image /src/ /src/
