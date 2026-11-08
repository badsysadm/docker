ARG VERSION=1.8.3

FROM oci.badsysadm.local:80/dep/lib/libunwind:${VERSION} AS build
ARG VERSION

WORKDIR /src/libunwind

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --enable-static \
    --enable-shared \
    --with-pic \
    --enable-ptrace \
    --disable-minidebuginfo \
    --disable-tests \
    CFLAGS="-O2 -fPIC"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/libexec/libunwind

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libunwind"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Portable stack unwinding libraries"
COPY --from=build /src/target/ /target/
