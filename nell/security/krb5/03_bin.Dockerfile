ARG VERSION=1.22.2

FROM oci.badsysadm.local:80/dep/security/krb5:${VERSION} AS dep_image


FROM dep_image AS build

ARG VERSION

WORKDIR /src/src


# ----------------------------------------------------------------------
# Configure
#
# Header'ы OpenLDAP берем от нашей сборки.
# Библиотеки здесь специально не подмешиваем через LDFLAGS:
# окончательный выбор static-библиотек делается ниже при make.
# ----------------------------------------------------------------------

RUN CFLAGS="-O2 -fcommon" \
    CPPFLAGS="-I/opt/deps/include" \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --enable-static \
        --disable-shared \
        --disable-rpath \
        --disable-nls \
        --with-ldap \
        --with-lmdb \
        --without-libedit \
        --without-system-verto \
        --without-keyutils


# ----------------------------------------------------------------------
# Build
#
# OpenLDAP + Cyrus SASL + OpenSSL + compression принудительно static.
#
# GSSAPI-зависимости libsasl2.a разрешаются уже библиотеками
# собираемого сейчас final krb5, а не bootstrap krb5.
# ----------------------------------------------------------------------

RUN LDAP_STATIC="\
-Wl,-Bstatic \
-Wl,--start-group \
-L/opt/deps/lib \
-lldap \
-llber \
-lsasl2 \
-lssl \
-lcrypto \
-lz \
-lzstd \
-Wl,--end-group \
-Wl,-Bdynamic" && \
    LMDB_STATIC="\
-Wl,-Bstatic \
-llmdb \
-Wl,-Bdynamic" && \
    make -j$(nproc) \
        LDAP_LIBS="${LDAP_STATIC}" \
        LMDB_LIBS="${LMDB_STATIC}" && \
    make install \
        DESTDIR=/src/target \
        LDAP_LIBS="${LDAP_STATIC}" \
        LMDB_LIBS="${LMDB_STATIC}"


# ----------------------------------------------------------------------
# Убираем documentation / examples / locale
# ----------------------------------------------------------------------

RUN rm -rf \
        /src/target/usr/share/man \
        /src/target/usr/share/doc \
        /src/target/usr/share/info \
        /src/target/usr/share/example \
        /src/target/usr/share/examples \
        /src/target/usr/share/locale


FROM scratch AS bundle

ARG VERSION

LABEL org.opencontainers.image.title="krb5"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="MIT Kerberos 5 bundle"

COPY --from=build /src/target/ /target/
