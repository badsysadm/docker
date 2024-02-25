FROM debian:12.4 AS base
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget gcc make libexpat1-dev libpcre3 libldap-dev libssl-dev libxml2-dev libc-ares2
WORKDIR /src
RUN wget https://dlcdn.apache.org/apr/apr-1.7.4.tar.gz
RUN tar -zxvf apr-1.7.4.tar.gz
WORKDIR apr-1.7.4
RUN sed -i 's|$RM "$cfgfile"|$RM -f "$cfgfile"|g' ./configure
RUN ./configure
RUN make
RUN make install
WORKDIR /src
RUN apt-get install slapd -y
RUN wget https://dlcdn.apache.org//apr/apr-util-1.6.3.tar.gz
RUN tar -zxvf apr-util-1.6.3.tar.gz
WORKDIR apr-util-1.6.3
RUN ./configure --with-apr=/usr/local/apr --with-crypto --with-openssl --with-ldap
RUN make
RUN make install
WORKDIR /src
RUN wget https://dlcdn.apache.org/httpd/httpd-2.4.58.tar.gz
RUN tar -zxvf httpd-2.4.58.tar.gz
WORKDIR httpd-2.4.58
RUN apt-get install -y libpcre3-dev libcurl4-openssl-dev libssl-dev libjansson-dev libc-ares-dev libpcre3
RUN ./configure --with-apr=/usr/local/apr --prefix="" --disable-shared --disable-so -enable-mods-static=all --enable-ssl-staticlib-deps --enable-md=false
RUN make
ENV DESTDIR=/opt
RUN make install
WORKDIR /opt/lib64
RUN cp -v /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /opt/lib64
WORKDIR /opt/lib
RUN cp -v /usr/lib/x86_64-linux-gnu/libzstd.so.1 \
          /usr/lib/x86_64-linux-gnu/libzstd.so.1.5.4 \
          /usr/lib/x86_64-linux-gnu/libz.so.1 \
          /usr/lib/x86_64-linux-gnu/libz.so.1.2.13 \
          /usr/lib/x86_64-linux-gnu/libxml2.so.2 \
          /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.14 \
          /usr/lib/x86_64-linux-gnu/libuuid.so.1 \
          /usr/lib/x86_64-linux-gnu/libuuid.so.1.3.0 \
          /usr/lib/x86_64-linux-gnu/libsystemd.so.0.35.0 \
          /usr/lib/x86_64-linux-gnu/libsystemd.so.0 \
          /usr/lib/x86_64-linux-gnu/libssl.so.3 \
          /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0 \
          /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0.11.2 \
          /usr/lib/x86_64-linux-gnu/libnghttp2.so.14.24.1 \
          /usr/lib/x86_64-linux-gnu/libnghttp2.so.14 \
          /usr/lib/x86_64-linux-gnu/libm.so.6 \
          /usr/lib/x86_64-linux-gnu/liblzma.so.5.4.1 \
          /usr/lib/x86_64-linux-gnu/liblzma.so.5 \
          /usr/lib/x86_64-linux-gnu/liblz4.so.1.9.4 \
          /usr/lib/x86_64-linux-gnu/liblz4.so.1 \
          /usr/lib/x86_64-linux-gnu/libjansson.so.4 \
          /usr/lib/x86_64-linux-gnu/libjansson.so.4.14.0 \
          /usr/lib/x86_64-linux-gnu/libgpg-error.so.0 \
          /usr/lib/x86_64-linux-gnu/libgpg-error.so.0.33.1 \
          /usr/lib/x86_64-linux-gnu/libgcrypt.so.20.4.1 \
          /usr/lib/x86_64-linux-gnu/libgcrypt.so.20 \
          /usr/lib/x86_64-linux-gnu/libexpat.so.1.8.10 \
          /usr/lib/x86_64-linux-gnu/libexpat.so.1 \
          /usr/lib/x86_64-linux-gnu/libcurl.so.4 \
          /usr/lib/x86_64-linux-gnu/libcurl.so.4.8.0 \
          /usr/lib/x86_64-linux-gnu/libcrypto.so.3 \
          /usr/lib/x86_64-linux-gnu/libcrypt.so \
          /usr/lib/x86_64-linux-gnu/libcrypt.so.1.1.0 \
          /usr/lib/x86_64-linux-gnu/libcrypt.so.1 \
          /usr/lib/x86_64-linux-gnu/libcares.so.2.5.1 \
          /usr/lib/x86_64-linux-gnu/libcares.so.2 \
          /usr/lib/x86_64-linux-gnu/libcares.so \
          /usr/lib/x86_64-linux-gnu/libcap.so.2.66 \
          /usr/lib/x86_64-linux-gnu/libcap.so.2 \
          /usr/lib/x86_64-linux-gnu/libc.so.6 \
          /usr/local/apr/lib/libaprutil-1.so.0 \
          /usr/local/apr/lib/libaprutil-1.so.0.6.3 \
          /usr/local/apr/lib/libapr-1.so.0 \
          /usr/local/apr/lib/libapr-1.so.0.7.4 \
          /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
          /usr/lib/x86_64-linux-gnu/libpcre.so.3 \
          /usr/lib/x86_64-linux-gnu/libpcre.so.3.13.3 \
          /usr/lib/x86_64-linux-gnu/libldap-2.5.so.0 \
          /usr/lib/x86_64-linux-gnu/liblber-2.5.so.0.1.8 /usr/lib/x86_64-linux-gnu/liblber-2.5.so.0 \
          /usr/lib/x86_64-linux-gnu/libidn2.so.0.3.8 /usr/lib/x86_64-linux-gnu/libidn2.so.0 \
          /usr/lib/x86_64-linux-gnu/librtmp.so.1 \
          /usr/lib/x86_64-linux-gnu/libssh2.so.1.0.1 /usr/lib/x86_64-linux-gnu/libssh2.so.1 \
          /usr/lib/x86_64-linux-gnu/libpsl.so.5.3.4 /usr/lib/x86_64-linux-gnu/libpsl.so.5 \
          /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2.2 \
          /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1 /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1.0.9 \
          /usr/lib/x86_64-linux-gnu/libicuuc.so.72.1 /usr/lib/x86_64-linux-gnu/libicuuc.so.72 \
          /usr/lib/x86_64-linux-gnu/libsasl2.so.2 /usr/lib/x86_64-linux-gnu/libsasl2.so.2.0.25 \
          /usr/lib/x86_64-linux-gnu/libgnutls.so.30 /usr/lib/x86_64-linux-gnu/libgnutls.so.30.34.3 \
          /usr/lib/x86_64-linux-gnu/libunistring.so.2.2.0 /usr/lib/x86_64-linux-gnu/libunistring.so.2 \
          /usr/lib/x86_64-linux-gnu/libhogweed.so.6.6 /usr/lib/x86_64-linux-gnu/libhogweed.so.6 \
          /usr/lib/x86_64-linux-gnu/libnettle.so.8.6 /usr/lib/x86_64-linux-gnu/libnettle.so.8 \
          /usr/lib/x86_64-linux-gnu/libgmp.so.10.4.1 /usr/lib/x86_64-linux-gnu/libgmp.so.10 \
          /usr/lib/x86_64-linux-gnu/libkrb5.so.3.3 /usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
          /usr/lib/x86_64-linux-gnu/libk5crypto.so.3.1 /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 \
          /usr/lib/x86_64-linux-gnu/libcom_err.so.2.1 /usr/lib/x86_64-linux-gnu/libcom_err.so.2 \
          /usr/lib/x86_64-linux-gnu/libkrb5support.so.0.1 /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
          /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1 /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1.0.9 \
          /usr/lib/x86_64-linux-gnu/libicudata.so.72 /usr/lib/x86_64-linux-gnu/libicudata.so.72.1 \
          /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.30 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
          /usr/lib/x86_64-linux-gnu/libgcc_s.so.1 \
          /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 /usr/lib/x86_64-linux-gnu/libp11-kit.so.0.3.0 \
          /usr/lib/x86_64-linux-gnu/libtasn1.so.6.6.3 /usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
          /usr/lib/x86_64-linux-gnu/libkeyutils.so.1.10 /usr/lib/x86_64-linux-gnu/libkeyutils.so.1 \
          /usr/lib/x86_64-linux-gnu/libresolv.so.2 \
          /usr/lib/x86_64-linux-gnu/libffi.so.8.1.2 /usr/lib/x86_64-linux-gnu/libffi.so.8 \
          /opt/lib
RUN mkdir -p /opt/etc /var/lib/httpd
RUN echo 'nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin' > /opt/etc/passwd
RUN echo 'nogroup:x:65534:' > /opt/etc/group
WORKDIR /
#RUN wget https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
#RUN chmod +x /busybox
RUN cp -rfv /opt/htdocs /var/lib/httpd/
RUN chown 65534:65534 -R /opt/logs /var/lib/httpd/
RUN mkdir -m 777 -p /tmp/httpd /var/run/httpd

FROM scratch
ENV HTTPD_PORT=8080
ENV HTTPD_USER=nobody HTTPD_GROUP=nogroup
ENV HTTPD_PIDFILE=/tmp/httpd/httpd.pid
ENV HTTPD_CGISOCK=/var/run/httpd/cgi.sock
COPY --from=base /opt/bin /bin
#COPY --from=base /opt/logs /logs
COPY --from=base /opt/etc /etc
COPY --from=base /opt/lib /lib
COPY --from=base /opt/lib64 /lib64
COPY --from=base /opt/conf /conf
COPY httpd.conf /conf/httpd.conf
COPY --from=base /usr/local/apr/lib/apr-util-1/apr_crypto_openssl-1.so /usr/local/apr/lib/apr-util-1/apr_crypto_openssl-1.so
#COPY --from=base /busybox /bin/busybox
COPY --from=base /var/lib/httpd /var/lib/httpd
COPY --from=base --chmod=777 /tmp/httpd /
COPY --from=base --chmod=777 /var/run/httpd /

USER nobody
CMD ["/bin/httpd", "-d", "/", "-D", "FOREGROUND"]
