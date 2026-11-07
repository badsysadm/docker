ARG VERSION=4.2.1

FROM oci.badsysadm.local:80/dep/security/audit:${VERSION} AS build
ARG VERSION

WORKDIR /src/audit

# Use the archive from the Debian development package rather than
# the shared libcap-ng object when libtool links libaudit.
RUN sed -i \
    's|CAPNG_LDADD=-lcap-ng|CAPNG_LDADD=/usr/lib/x86_64-linux-gnu/libcap-ng.a|' \
    m4/cap-ng.m4
RUN autoreconf -f -i

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --runstatedir=/run \
    --libdir=/usr/lib \
    --enable-static \
    --enable-shared \
    --with-libcap-ng=yes \
    --disable-zos-remote \
    --without-python3 \
    --without-golang \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/lib/x86_64-linux-gnu/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="audit"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux Audit userspace daemon, tools and static libraries"
COPY --from=build /src/target/ /target/
