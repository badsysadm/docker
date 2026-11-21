ARG VERSION=262.2
ARG OPENSSL_VERSION=3.6.5
ARG LIBGCRYPT_VERSION=1.12.4
ARG LIBGPG_ERROR_VERSION=1.61
ARG UTIL_LINUX_VERSION=2.42.2
ARG ACL_VERSION=2.4.0
ARG APPARMOR_VERSION=4.1.8
ARG AUDIT_VERSION=4.2.1
ARG LIBCAP_NG_VERSION=0.8.5
ARG BZIP2_VERSION=1.0.8
ARG CRACKLIB_VERSION=2.10.3
ARG CURL_VERSION=8.23.0
ARG ELFUTILS_VERSION=0.196
ARG GLIB_VERSION=2.84.4
ARG GNUTLS_VERSION=3.8.14
ARG LIBLZ4_VERSION=1.10.0
ARG LIBPCRE2_VERSION=10.49
ARG LIBBPF_VERSION=1.8.0
ARG DBUS_VERSION=1.16.2
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7
ARG XZUTILS_VERSION=5.6.2

FROM oci.badsysadm.local:80/src/system/systemd:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/libgcrypt:${LIBGCRYPT_VERSION} AS libgcrypt_image
FROM oci.badsysadm.local:80/bin/lib/libgpg-error:${LIBGPG_ERROR_VERSION} AS libgpg_error_image
FROM oci.badsysadm.local:80/bin/utils/util-linux:${UTIL_LINUX_VERSION} AS util_linux_image
FROM oci.badsysadm.local:80/bin/security/acl:${ACL_VERSION} AS acl_image
FROM oci.badsysadm.local:80/bin/security/apparmor:${APPARMOR_VERSION} AS apparmor_image
FROM oci.badsysadm.local:80/bin/security/audit:${AUDIT_VERSION} AS audit_image
FROM oci.badsysadm.local:80/bin/lib/libcap-ng:${LIBCAP_NG_VERSION} AS libcap_ng_image
FROM oci.badsysadm.local:80/bin/lib/bzip2:${BZIP2_VERSION} AS bzip2_image
FROM oci.badsysadm.local:80/bin/security/cracklib:${CRACKLIB_VERSION} AS cracklib_image
FROM oci.badsysadm.local:80/bin/net/curl:${CURL_VERSION} AS curl_image
FROM oci.badsysadm.local:80/bin/utils/elfutils:${ELFUTILS_VERSION} AS elfutils_image
FROM oci.badsysadm.local:80/bin/lib/glib:${GLIB_VERSION} AS glib_image
FROM oci.badsysadm.local:80/bin/security/gnutls:${GNUTLS_VERSION} AS gnutls_image
FROM oci.badsysadm.local:80/bin/lib/liblz4:${LIBLZ4_VERSION} AS liblz4_image
FROM oci.badsysadm.local:80/bin/lib/libpcre2:${LIBPCRE2_VERSION} AS libpcre2_image
FROM oci.badsysadm.local:80/bin/lib/libbpf:${LIBBPF_VERSION} AS libbpf_image
FROM oci.badsysadm.local:80/bin/system/dbus:${DBUS_VERSION} AS dbus_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/bin/utils/xzutils:${XZUTILS_VERSION} AS xzutils_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION

COPY debian ./debian/
RUN sed -i "1s/@VERSION@/${VERSION}/" debian/changelog
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=openssl_image /target/usr/include/ /usr/include/
COPY --from=acl_image /target/usr/include/ /usr/include/
COPY --from=apparmor_image /target/usr/include/ /usr/include/
COPY --from=audit_image /target/usr/include/ /usr/include/
COPY --from=libcap_ng_image /target/usr/include/ /usr/include/
COPY --from=bzip2_image /target/usr/include/ /usr/include/
COPY --from=cracklib_image /target/usr/include/ /usr/include/
COPY --from=curl_image /target/usr/include/ /usr/include/
COPY --from=elfutils_image /target/usr/include/ /usr/include/
COPY --from=glib_image /target/usr/include/ /usr/include/
COPY --from=gnutls_image /target/usr/include/ /usr/include/
COPY --from=liblz4_image /target/usr/include/ /usr/include/
COPY --from=libpcre2_image /target/usr/include/ /usr/include/
COPY --from=libbpf_image /target/usr/include/ /usr/include/
COPY --from=dbus_image /target/usr/include/ /usr/include/
COPY --from=zlib_image /target/usr/include/ /usr/include/
COPY --from=zstd_image /target/usr/include/ /usr/include/
COPY --from=xzutils_image /target/usr/include/ /usr/include/
COPY --from=libgcrypt_image /target/usr/include/ /usr/include/
COPY --from=libgpg_error_image /target/usr/include/ /usr/include/
COPY --from=util_linux_image /target/usr/include/ /usr/include/

COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/lib64/libcrypto.a
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/lib64/libssl.a
COPY --from=acl_image /target/usr/lib/x86_64-linux-gnu/libacl.a /usr/lib/x86_64-linux-gnu/libacl.a
COPY --from=apparmor_image /target/usr/lib/x86_64-linux-gnu/libapparmor.a /usr/lib/x86_64-linux-gnu/libapparmor.a
COPY --from=audit_image /target/usr/lib/libaudit.a /usr/lib/x86_64-linux-gnu/libaudit.a
COPY --from=libcap_ng_image /target/usr/lib/libcap-ng.a /usr/lib/x86_64-linux-gnu/libcap-ng.a
COPY --from=bzip2_image /target/usr/lib/libbz2.a /usr/lib/x86_64-linux-gnu/libbz2.a
COPY --from=cracklib_image /target/usr/lib/libcrack.a /usr/lib/x86_64-linux-gnu/libcrack.a
COPY --from=curl_image /target/usr/lib/libcurl.a /usr/lib/x86_64-linux-gnu/libcurl.a
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/libelf.a /usr/lib/x86_64-linux-gnu/libelf.a
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/libdw.a /usr/lib/x86_64-linux-gnu/libdw.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/glib-2.0/include/ /usr/lib/x86_64-linux-gnu/glib-2.0/include/
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libglib-2.0.a /usr/lib/x86_64-linux-gnu/libglib-2.0.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libgobject-2.0.a /usr/lib/x86_64-linux-gnu/libgobject-2.0.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libgio-2.0.a /usr/lib/x86_64-linux-gnu/libgio-2.0.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libgmodule-2.0.a /usr/lib/x86_64-linux-gnu/libgmodule-2.0.a
COPY --from=gnutls_image /target/usr/lib/libgnutls.a /usr/lib/x86_64-linux-gnu/libgnutls.a
COPY --from=liblz4_image /target/usr/lib/liblz4.a /usr/lib/x86_64-linux-gnu/liblz4.a
COPY --from=libpcre2_image /target/usr/lib/libpcre2-8.a /usr/lib/x86_64-linux-gnu/libpcre2-8.a
COPY --from=libbpf_image /target/usr/lib/libbpf.a /usr/lib/x86_64-linux-gnu/libbpf.a
COPY --from=dbus_image /target/usr/lib/x86_64-linux-gnu/dbus-1.0/include/ /usr/lib/x86_64-linux-gnu/dbus-1.0/include/
COPY --from=dbus_image /target/usr/lib/x86_64-linux-gnu/libdbus-1.a /usr/lib/x86_64-linux-gnu/libdbus-1.a
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/lib/x86_64-linux-gnu/libz.a
COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/lib/x86_64-linux-gnu/libzstd.a
COPY --from=xzutils_image /target/usr/lib/x86_64-linux-gnu/liblzma.a /usr/lib/x86_64-linux-gnu/liblzma.a

COPY --from=libgcrypt_image /target/usr/lib/libgcrypt.a /usr/lib/x86_64-linux-gnu/libgcrypt.a
COPY --from=libgpg_error_image /target/usr/lib/libgpg-error.a /usr/lib/x86_64-linux-gnu/libgpg-error.a
COPY --from=util_linux_image /target/usr/lib/libblkid.a /usr/lib/x86_64-linux-gnu/libblkid.a
COPY --from=util_linux_image /target/usr/lib/libmount.a /usr/lib/x86_64-linux-gnu/libmount.a
COPY --from=util_linux_image /target/usr/lib/libfdisk.a /usr/lib/x86_64-linux-gnu/libfdisk.a

COPY --from=src_image /src/ /src