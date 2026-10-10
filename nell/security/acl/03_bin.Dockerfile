ARG VERSION=2.4.0

FROM oci.badsysadm.local:80/dep/security/acl:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/acl

RUN ./configure \
        --prefix=/usr \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --enable-static \
        --enable-shared \
        --disable-nls

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info \
        /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="acl"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="POSIX access control list utilities and library"

COPY --from=build /src/target/ /target/
