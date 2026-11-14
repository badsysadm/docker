ARG VERSION=1.0.5

FROM oci.badsysadm.local:80/dep/lib/libmnl:${VERSION} AS build
ARG VERSION

WORKDIR /src/libmnl

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --enable-static \
    --enable-shared \
    --with-pic \
    CFLAGS="-O2 -fPIC -D_FORTIFY_SOURCE=3 -fstack-protector-strong -fstack-clash-protection -fcf-protection=full -ftrivial-auto-var-init=zero -ffunction-sections -fdata-sections" \
    LDFLAGS="-Wl,-z,relro,-z,now -Wl,--gc-sections"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/x86_64-linux-gnu/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libmnl"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Minimalistic Netlink user-space library"
COPY --from=build /src/target/ /target/
