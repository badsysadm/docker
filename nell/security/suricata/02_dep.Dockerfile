ARG VERSION=8.0.8
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1

FROM oci.badsysadm.local:80/src/security/suricata:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib64/libcrypto.a
COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a

COPY --from=src_image /src/ /src/

WORKDIR /src/suricata

# Upstream autogen.sh removes rust/Cargo.lock; retain the tagged lockfile.
# Suricata links its executable using src/Makefile.am rather than LDFLAGS alone.
# Select static archives for its dependencies, then return to dynamic libc.
RUN sed -i \
    -e 's|^suricata_LDFLAGS = .*|suricata_LDFLAGS = -Wl,-Bstatic $(all_libraries) ${SECLDFLAGS}|' \
    -e 's|^suricata_LDADD = .*|suricata_LDADD = $(LDADD_GENERIC) $(LIBS) -Wl,-Bdynamic|' \
    src/Makefile.am
RUN autoreconf -fvi
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-unittests \
    --disable-gccmarch-native \
    --disable-suricata-update \
    --disable-python \
    --enable-nfqueue \
    --enable-nflog \
    --enable-ebpf \
    --enable-ebpf-build \
    --disable-af-xdp \
    --disable-dpdk \
    --disable-pfring \
    --enable-libmagic \
    --enable-geoip

# Download crates during dependency preparation, never during binary build.
RUN cd rust && cargo vendor --locked vendor > /tmp/suricata-cargo-vendor.toml
RUN test -s /tmp/suricata-cargo-vendor.toml && \
    mkdir -p rust/.cargo && \
    cp /tmp/suricata-cargo-vendor.toml rust/.cargo/config.toml
