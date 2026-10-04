ARG VERSION=5.44.0

FROM oci.badsysadm.local:80/dep/perl/perl:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

RUN ./Configure -des \
    -Dprefix=/usr \
    -Dvendorprefix=/usr \
    -Dsiteprefix=/usr/local \
    -Dprivlib=/usr/share/perl5/${VERSION} \
    -Darchlib=/usr/lib/x86_64-linux-gnu/perl5/${VERSION} \
    -Dvendorlib=/usr/share/perl5/${VERSION} \
    -Dvendorarch=/usr/lib/x86_64-linux-gnu/perl5/${VERSION} \
    -Dsitelib=/usr/local/share/perl5/${VERSION} \
    -Dsitearch=/usr/local/lib/x86_64-linux-gnu/perl5/${VERSION} \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dhtml1dir=/usr/share/doc/perl/html \
    -Dhtml3dir=/usr/share/doc/perl/html \
    -Dnoopts \
    -Usupport_libcrypt \
    -Dno-posix-2008 \
    -Dldflags="-static-libgcc" \
    -Dlibswanted="m c"
RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN find /src/target/usr/share/perl5 -name "*.pod" -delete -o -type d -name "pod" -exec rm -rf {} +
RUN rm -rf /src/target/usr/share/man /src/target/usr/share/doc /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="perl"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="perl binary and tools"
COPY --from=build /src/target/ /target/
