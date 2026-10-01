ARG VERSION=2.44

FROM oci.badsysadm.local:80/dep/system/glibc:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/glibc/build
RUN ../configure --prefix=/usr
RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

ARG LOCALES="en_US.UTF-8/UTF-8 ru_RU.UTF-8/UTF-8"
RUN echo "SUPPORTED-LOCALES=\\" > ../localedata/SUPPORTED && \
    for loc in ${LOCALES}; do echo "$loc \\" >> ../localedata/SUPPORTED; done
RUN make localedata/install-locale-files DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="glibc"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="glibc bundle"
COPY --from=build /src/target/ /target/
