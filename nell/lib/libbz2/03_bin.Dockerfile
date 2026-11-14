ARG VERSION=1.0.8

FROM oci.badsysadm.local:80/dep/lib/libbz2:${VERSION} AS build
ARG VERSION

WORKDIR /src/bzip2

RUN make -j$(nproc) libbz2.a CFLAGS="-O2 -fPIC -D_FILE_OFFSET_BITS=64"
RUN make -f Makefile-libbz2_so CFLAGS="-O2 -fPIC -D_FILE_OFFSET_BITS=64"

RUN install -D -m 0644 bzlib.h /src/target/usr/include/bzlib.h
RUN install -D -m 0644 libbz2.a /src/target/usr/lib/libbz2.a
RUN install -D -m 0755 libbz2.so.1.0.8 /src/target/usr/lib/libbz2.so.1.0.8
RUN ln -s libbz2.so.1.0.8 /src/target/usr/lib/libbz2.so.1.0
RUN ln -s libbz2.so.1.0 /src/target/usr/lib/libbz2.so

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libbz2"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Bzip2 static and shared compression libraries"
COPY --from=build /src/target/ /target/
