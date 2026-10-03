ARG VERSION=1.22.2
ARG SASL_VERSION=2.1.28
ARG OPENLDAP_VERSION=2.6.15


FROM oci.badsysadm.local:80/src/security/krb5:${VERSION} AS src_image


FROM oci.badsysadm.local:80/get/source:latest AS deps_src

ARG SASL_VERSION
ARG OPENLDAP_VERSION

RUN mkdir -p /src/cyrus-sasl /src/openldap && \
    wget -qO- \
        https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-${SASL_VERSION}/cyrus-sasl-${SASL_VERSION}.tar.gz | \
        tar -xzf - -C /src/cyrus-sasl --strip-components=1 && \
    wget -qO- \
        https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz | \
        tar -xzf - -C /src/openldap --strip-components=1


FROM oci.badsysadm.local:80/get/dep:latest AS dep_base

COPY debian ./debian/

RUN apt-get -qq update
RUN mk-build-deps \
        --install \
        --remove \
        --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' \
        debian/control

COPY --from=src_image /src/ /src/


FROM dep_base AS deps_builder

COPY --from=deps_src /src/cyrus-sasl/ /build-src/cyrus-sasl/
COPY --from=deps_src /src/openldap/ /build-src/openldap/


# ----------------------------------------------------------------------
# Bootstrap krb5
#
# Нужен исключительно для сборки GSSAPI-механизма Cyrus SASL.
# Устанавливается в отдельный prefix и в итоговый dep-образ не попадет.
# ----------------------------------------------------------------------

RUN mkdir -p /build/krb5-bootstrap && \
    cd /build/krb5-bootstrap && \
    CFLAGS="-O2 -fcommon" \
    /src/src/configure \
        --prefix=/opt/bootstrap/krb5 \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --enable-static \
        --disable-shared \
        --disable-rpath \
        --disable-nls \
        --without-ldap \
        --without-lmdb \
        --without-libedit \
        --without-system-verto \
        --without-keyutils && \
    make -j$(nproc) && \
    make install


# ----------------------------------------------------------------------
# Cyrus SASL
#
# Оставляем GSSAPI для FreeIPA/OpenLDAP.
# SQL/LDAPDB отключаем, чтобы libsasl2.a не тянул PostgreSQL,
# MySQL, SQLite и обратную зависимость на OpenLDAP.
# ----------------------------------------------------------------------

WORKDIR /build-src/cyrus-sasl

RUN find . -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

# Cyrus SASL 2.1.28 + GCC 14
RUN sed -i \
    's/^#ifdef HAVE_TIME_H$/#ifdef HAVE_SYS_TIME_H/' \
    lib/saslutil.c

RUN export PATH="/opt/bootstrap/krb5/bin:${PATH}" && \
    export CPPFLAGS="-I/opt/bootstrap/krb5/include" && \
    export LDFLAGS="-L/opt/bootstrap/krb5/lib" && \
    export LIBS="-lkrb5support -lresolv -ldl -lpthread" && \
    ./configure \
        --prefix=/opt/deps \
        --enable-static \
        --disable-shared \
        --enable-gssapi=/opt/bootstrap/krb5 \
        --with-gss_impl=mit \
        --disable-cram \
        --disable-digest \
        --disable-scram \
        --disable-otp \
        --disable-plain \
        --disable-anon \
        --disable-sql \
        --disable-ldapdb \
        --disable-sample \
        --with-dblib=none \
        --without-saslauthd \
        --without-pam

RUN make -C include -j$(nproc) && \
    make -C sasldb -j$(nproc) && \
    make -C common -j$(nproc) && \
    make -C lib -j$(nproc)

RUN make -C include install && \
    make -C lib install && \
    find /opt/deps -name '*.la' -delete

# ----------------------------------------------------------------------
# OpenLDAP client libraries
#
# slapd нам не нужен. Нужны только libldap.a/liblber.a,
# собранные с Cyrus SASL и TLS.
#
# На этом этапе bootstrap krb5 используется только для разрешения
# GSSAPI-зависимостей при сборке OpenLDAP.
# ----------------------------------------------------------------------

WORKDIR /build-src/openldap

RUN export PATH="/opt/bootstrap/krb5/bin:${PATH}" && \
    export CPPFLAGS="\
        -I/opt/deps/include \
        -I/opt/bootstrap/krb5/include" && \
    export LDFLAGS="\
        -L/opt/deps/lib \
        -L/opt/bootstrap/krb5/lib" && \
    export LIBS="\
        -Wl,--start-group \
        /opt/bootstrap/krb5/lib/libgssapi_krb5.a \
        /opt/bootstrap/krb5/lib/libkrb5.a \
        /opt/bootstrap/krb5/lib/libk5crypto.a \
        /opt/bootstrap/krb5/lib/libcom_err.a \
        /opt/bootstrap/krb5/lib/libkrb5support.a \
        -Wl,--end-group \
        -lresolv \
        -ldl \
        -lpthread" && \
    ./configure \
        --prefix=/opt/deps \
        --enable-static \
        --disable-shared \
        --disable-slapd \
        --disable-balancer \
        --disable-debug \
        --with-cyrus-sasl \
        --with-tls=openssl && \
    make depend && \
    make -j$(nproc) && \
    make install

# Оставляем только то, что понадобится при финальной сборке krb5.
#
# Особенно важно удалить .la: libtool metadata может содержать
# dependency_libs со ссылками на bootstrap prefix.

RUN find /opt/deps -name '*.la' -delete && \
    rm -rf \
        /opt/deps/bin \
        /opt/deps/sbin \
        /opt/deps/share \
        /opt/deps/lib/sasl2


# ----------------------------------------------------------------------
# Итоговый образ зависимостей
#
# /opt/bootstrap сюда вообще не копируется.
# ----------------------------------------------------------------------

FROM dep_base

COPY --from=deps_builder /opt/deps/ /opt/deps/
