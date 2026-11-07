ARG VERSION=3.12

FROM oci.badsysadm.local:80/dep/utils/grep:${VERSION} AS build
ARG VERSION

WORKDIR /src/grep

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --libdir=/usr/lib64 \
    --disable-nls \
    LDFLAGS="-static-libgcc" \
    LIBS="-Wl,-Bstatic -lpcre2-8 -Wl,-Bdynamic"

RUN make -j$(nproc)
RUN make DESTDIR=/src/target install

RUN rm -rf /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="grep"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU grep text search utilities"
COPY --from=build /src/target/ /target/
