ARG VERSION=3.5.3
ARG NCURSES_VERSION=6.6

FROM oci.badsysadm.local:80/src/tui/htop:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/ncurses:${NCURSES_VERSION} AS ncurses_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=ncurses_image /target/usr/include/ /usr/local/include/
COPY --from=ncurses_image /target/lib/x86_64-linux-gnu/ /usr/local/lib/

RUN cp /usr/lib/x86_64-linux-gnu/libcap.a \
       /usr/lib/x86_64-linux-gnu/libhwloc.a \
       /usr/lib/x86_64-linux-gnu/libunwind.a \
       /usr/lib/x86_64-linux-gnu/libunwind-ptrace.a \
       /usr/lib/x86_64-linux-gnu/libunwind-generic.a \
       /usr/lib/x86_64-linux-gnu/libunwind-x86_64.a \
       /usr/lib/x86_64-linux-gnu/liblzma.a \
       /usr/lib/x86_64-linux-gnu/libxml2.a \
       /usr/lib/x86_64-linux-gnu/libnuma.a \
       /usr/lib/x86_64-linux-gnu/libltdl.a \
       /usr/local/lib/

COPY --from=src_image /src/ /src/
