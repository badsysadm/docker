ARG VERSION=0.69

FROM oci.badsysadm.local:80/dep/dev/quilt:${VERSION} AS build
ARG VERSION

WORKDIR /src/quilt

# quilt is primarily a Bash script suite; retain upstream entrypoints and
# installed runtime helpers rather than converting scripts into PAR binaries.
RUN ./configure --prefix=/usr --disable-nls

RUN make -j$(nproc) && \
    make install DESTDIR=/src/target

# Remove documentation only; retain upstream runtime files and completions.
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/locale

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="quilt"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Quilt patch stack management tools"
COPY --from=build /src/target/ /target/
