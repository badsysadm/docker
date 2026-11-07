ARG VERSION=2.25

FROM oci.badsysadm.local:80/dep/utils/which:${VERSION} AS build
ARG VERSION

WORKDIR /src/which

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +
RUN ./configure \
    --prefix=/usr \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc)
RUN make DESTDIR=/src/target install
RUN rm -rf /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="which"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU which command lookup utility"
COPY --from=build /src/target/ /target/
