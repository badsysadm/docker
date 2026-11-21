ARG VERSION=262.2
ARG OPENSSL_VERSION=3.6.5
ARG LIBGCRYPT_VERSION=1.12.4
ARG LIBGPG_ERROR_VERSION=1.61
ARG UTIL_LINUX_VERSION=2.42.2
ARG ACL_VERSION=2.4.0
ARG APPARMOR_VERSION=4.1.8
ARG AUDIT_VERSION=4.2.1
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

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/lib64/libcrypto.a
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/lib64/libssl.a
COPY --from=openssl_image /target/usr/lib64/pkgconfig/ /usr/lib64/pkgconfig/
COPY --from=acl_image /target/usr/include/sys/acl.h /usr/local/include/sys/acl.h
COPY --from=acl_image /target/usr/lib/x86_64-linux-gnu/libacl.a /usr/local/lib/libacl.a
COPY --from=apparmor_image /target/usr/include/sys/apparmor.h /usr/local/include/sys/apparmor.h
COPY --from=apparmor_image /target/usr/lib/x86_64-linux-gnu/libapparmor.a /usr/local/lib/libapparmor.a
COPY --from=audit_image /target/usr/include/libaudit.h /usr/local/include/libaudit.h
COPY --from=audit_image /target/usr/lib/libaudit.a /usr/local/lib/libaudit.a
COPY --from=curl_image /target/usr/include/curl/ /usr/local/include/curl/
COPY --from=curl_image /target/usr/lib/libcurl.a /usr/local/lib/libcurl.a
COPY --from=curl_image /target/usr/lib/pkgconfig/libcurl.pc /usr/local/lib/pkgconfig/libcurl.pc
COPY --from=elfutils_image /target/usr/include/elfutils/ /usr/local/include/elfutils/
COPY --from=elfutils_image /target/usr/include/libelf.h /usr/local/include/libelf.h
COPY --from=elfutils_image /target/usr/include/gelf.h /usr/local/include/gelf.h
COPY --from=elfutils_image /target/usr/include/dwarf.h /usr/local/include/dwarf.h
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/libelf.a /usr/local/lib/libelf.a
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/libdw.a /usr/local/lib/libdw.a
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/pkgconfig/libelf.pc /usr/local/lib/pkgconfig/libelf.pc
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/pkgconfig/libdw.pc /usr/local/lib/pkgconfig/libdw.pc
COPY --from=glib_image /target/usr/include/glib-2.0/ /usr/local/include/glib-2.0/
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/glib-2.0/include/ /usr/local/lib/glib-2.0/include/
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libglib-2.0.a /usr/local/lib/libglib-2.0.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libgobject-2.0.a /usr/local/lib/libgobject-2.0.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libgio-2.0.a /usr/local/lib/libgio-2.0.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/libgmodule-2.0.a /usr/local/lib/libgmodule-2.0.a
COPY --from=glib_image /target/usr/lib/x86_64-linux-gnu/pkgconfig/ /usr/local/lib/pkgconfig/
COPY --from=gnutls_image /target/usr/include/gnutls/ /usr/local/include/gnutls/
COPY --from=gnutls_image /target/usr/lib/libgnutls.a /usr/local/lib/libgnutls.a
COPY --from=gnutls_image /target/usr/lib/pkgconfig/gnutls.pc /usr/local/lib/pkgconfig/gnutls.pc
COPY --from=liblz4_image /target/usr/include/lz4.h /usr/local/include/lz4.h
COPY --from=liblz4_image /target/usr/include/lz4frame.h /usr/local/include/lz4frame.h
COPY --from=liblz4_image /target/usr/include/lz4hc.h /usr/local/include/lz4hc.h
COPY --from=liblz4_image /target/usr/lib/liblz4.a /usr/local/lib/liblz4.a
COPY --from=liblz4_image /target/usr/lib/pkgconfig/liblz4.pc /usr/local/lib/pkgconfig/liblz4.pc
COPY --from=libpcre2_image /target/usr/include/pcre2.h /usr/local/include/pcre2.h
COPY --from=libpcre2_image /target/usr/lib/libpcre2-8.a /usr/local/lib/libpcre2-8.a
COPY --from=libpcre2_image /target/usr/lib/pkgconfig/libpcre2-8.pc /usr/local/lib/pkgconfig/libpcre2-8.pc
COPY --from=libbpf_image /target/usr/include/bpf/ /usr/local/include/bpf/
COPY --from=libbpf_image /target/usr/lib/libbpf.a /usr/local/lib/libbpf.a
COPY --from=libbpf_image /target/usr/lib/pkgconfig/libbpf.pc /usr/local/lib/pkgconfig/libbpf.pc
COPY --from=dbus_image /target/usr/include/dbus-1.0/ /usr/local/include/dbus-1.0/
COPY --from=dbus_image /target/usr/lib/x86_64-linux-gnu/dbus-1.0/include/ /usr/local/lib/dbus-1.0/include/
COPY --from=dbus_image /target/usr/lib/x86_64-linux-gnu/libdbus-1.a /usr/local/lib/libdbus-1.a
COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a
COPY --from=zstd_image /target/usr/include/zstd.h /usr/local/include/zstd.h
COPY --from=zstd_image /target/usr/include/zdict.h /usr/local/include/zdict.h
COPY --from=zstd_image /target/usr/include/zstd_errors.h /usr/local/include/zstd_errors.h
COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/local/lib/libzstd.a
COPY --from=xzutils_image /target/usr/include/lzma.h /usr/local/include/lzma.h
COPY --from=xzutils_image /target/usr/include/lzma/ /usr/local/include/lzma/
COPY --from=xzutils_image /target/usr/lib/x86_64-linux-gnu/liblzma.a /usr/local/lib/liblzma.a

COPY --from=libgcrypt_image /target/usr/include/gcrypt.h /usr/local/include/gcrypt.h
COPY --from=libgcrypt_image /target/usr/lib/libgcrypt.a /usr/local/lib/libgcrypt.a
COPY --from=libgcrypt_image /target/usr/lib/pkgconfig/libgcrypt.pc /usr/local/lib/pkgconfig/libgcrypt.pc
COPY --from=libgpg_error_image /target/usr/include/gpg-error.h /usr/local/include/gpg-error.h
COPY --from=libgpg_error_image /target/usr/lib/libgpg-error.a /usr/local/lib/libgpg-error.a
COPY --from=libgpg_error_image /target/usr/lib/pkgconfig/gpg-error.pc /usr/local/lib/pkgconfig/gpg-error.pc
COPY --from=util_linux_image /target/usr/include/blkid/ /usr/local/include/blkid/
COPY --from=util_linux_image /target/usr/include/libmount/ /usr/local/include/libmount/
COPY --from=util_linux_image /target/usr/include/libfdisk/ /usr/local/include/libfdisk/
COPY --from=util_linux_image /target/usr/lib/libblkid.a /usr/local/lib/libblkid.a
COPY --from=util_linux_image /target/usr/lib/libmount.a /usr/local/lib/libmount.a
COPY --from=util_linux_image /target/usr/lib/libfdisk.a /usr/local/lib/libfdisk.a
COPY --from=util_linux_image /target/usr/lib/pkgconfig/blkid.pc /usr/local/lib/pkgconfig/blkid.pc
COPY --from=util_linux_image /target/usr/lib/pkgconfig/mount.pc /usr/local/lib/pkgconfig/mount.pc
COPY --from=util_linux_image /target/usr/lib/pkgconfig/fdisk.pc /usr/local/lib/pkgconfig/fdisk.pc

COPY --from=src_image /src/ /src