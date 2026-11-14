ARG VERSION=8.0.8
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7
ARG DBUS_VERSION=1.16.2
ARG ELFUTILS_VERSION=0.196
ARG LIBNFNETLINK_VERSION=1.0.2
ARG LIBNETFILTER_LOG_VERSION=1.0.2

FROM oci.badsysadm.local:80/src/security/suricata:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/bin/system/dbus:${DBUS_VERSION} AS dbus_image
FROM oci.badsysadm.local:80/bin/utils/elfutils:${ELFUTILS_VERSION} AS elfutils_image
FROM oci.badsysadm.local:80/bin/lib/libnfnetlink:${LIBNFNETLINK_VERSION} AS libnfnetlink_image
FROM oci.badsysadm.local:80/bin/lib/libnetfilter-log:${LIBNETFILTER_LOG_VERSION} AS libnetfilter_log_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib/libcrypto.a
COPY --from=zlib_image /target/usr/include/ /usr/local/include/
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a
COPY --from=zstd_image /target/usr/include/ /usr/local/include/
COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/local/lib/libzstd.a
COPY --from=dbus_image /target/usr/lib/x86_64-linux-gnu/libdbus-1.a /usr/local/lib/libdbus-1.a
COPY --from=elfutils_image /target/usr/include/ /usr/local/include/
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/libelf.a /usr/local/lib/libelf.a
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/pkgconfig/libelf.pc /usr/local/lib/pkgconfig/libelf.pc

COPY --from=libnfnetlink_image /target/usr/local/include/ /usr/local/include/
COPY --from=libnfnetlink_image /target/usr/local/lib/ /usr/local/lib/
COPY --from=libnetfilter_log_image /target/usr/local/include/ /usr/local/include/
COPY --from=libnetfilter_log_image /target/usr/local/lib/ /usr/local/lib/

COPY --from=src_image /src/ /src/

WORKDIR /src/suricata

# Prepare Cargo manifests for vendoring.
ARG VERSION
RUN for manifest in \
        rust/Cargo.toml.in \
        rust/derive/Cargo.toml.in \
        rust/sys/Cargo.toml.in \
        rust/htp/Cargo.toml.in \
        rust/suricatactl/Cargo.toml.in \
        rust/suricatasc/Cargo.toml.in; do \
        sed "s/@PACKAGE_VERSION@/${VERSION}/g" "$manifest" > "${manifest%.in}"; \
    done && \
    install -m 0644 rust/Cargo.lock.in rust/Cargo.lock

# Download crates during dependency preparation.
RUN cd rust && cargo vendor --locked vendor > /tmp/suricata-cargo-vendor.toml
RUN install -D -m 0644 /tmp/suricata-cargo-vendor.toml rust/.cargo/config.toml
