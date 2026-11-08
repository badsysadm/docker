ARG VERSION=3.5.3
ARG NCURSES_VERSION=6.6
ARG ZLIB_VERSION=1.3.1
ARG LIBUNWIND_VERSION=1.8.3
ARG SYSTEMD_VERSION=261

FROM oci.badsysadm.local:80/src/tui/htop:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/ncurses:${NCURSES_VERSION} AS ncurses_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/lib/libunwind:${LIBUNWIND_VERSION} AS libunwind_image
FROM oci.badsysadm.local:80/bin/system/systemd:${SYSTEMD_VERSION} AS systemd_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=ncurses_image /target/usr/include/ /usr/local/include/
COPY --from=ncurses_image /target/usr/lib/ /usr/local/lib/

RUN for lib in libcap.a libhwloc.a liblzma.a libxml2.a libnuma.a libltdl.a; do \
        install -D "/usr/lib/x86_64-linux-gnu/$lib" "/usr/local/lib/$lib" || exit 1; \
    done

COPY --from=libunwind_image /target/usr/include/ /usr/local/include/
COPY --from=libunwind_image /target/usr/lib/ /usr/local/lib/

COPY --from=systemd_image /target/usr/lib/libudev.a /usr/local/lib/libudev.a

COPY --from=zlib_image /target/usr/lib/libz.a /usr/local/lib/libz.a

COPY --from=src_image /src/ /src/
