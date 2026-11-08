ARG VERSION=1.3-20260721

FROM oci.badsysadm.local:80/dep/usr/dialog:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/dialog

RUN sed -n '/dialog\$o.*-L\./p' makefile.in > /tmp/dialog-link-rule && \
    test "$(wc -l < /tmp/dialog-link-rule)" -eq 1 && \
    sed -i '/dialog\$o.*-L\./c\\\t$(CC) $(CFLAGS) -o $@ dialog$o .libs/libdialog.a /usr/local/lib/libncursesw.a $(LDFLAGS) -Wl,-Bstatic -lm -Wl,-Bdynamic' makefile.in && \
    grep -Fq '.libs/libdialog.a /usr/local/lib/libncursesw.a' makefile.in
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/usr/bin \
    --libdir=/usr/lib \
    --mandir=/usr/share/man \
    --with-ncursesw \
    --enable-widec \
    --with-shared \
    --with-libtool \
    --disable-rpath-hack \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib -static-libgcc" \
    LIBS="-Wl,-Bstatic -lncursesw -Wl,-Bdynamic"
RUN make -j$(nproc)
RUN make install install-lib DESTDIR=/src/target
RUN find /src/target -name '*.la' -delete
RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="dialog"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="dialog bundle"
COPY --from=build /src/target/ /target/
