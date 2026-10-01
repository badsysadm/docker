ARG VERSION=9.5

FROM oci.badsysadm.local:80/dep/usr/coreutils:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION
ARG FORCE_UNSAFE_CONFIGURE=1

WORKDIR /src/coreutils
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-nls \
    --enable-single-binary=symlinks

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
    
FROM scratch AS bundle
LABEL org.opencontainers.image.title="coreutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU coreutils single binary"
COPY --from=build /src/target/ /target/
