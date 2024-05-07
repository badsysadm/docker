FROM gentoo/stage3:systemd-20240219 AS build
RUN emerge --sync
ENV USE="-dco iproute2 -mbedtls openssl pkcs11 plugins -examples inotify lz4 lzo pam -selinux systemd -test"
RUN echo -e '\
                  =net-vpn/openvpn-2.6.9       ~amd64 \n\
            '> /etc/portage/package.accept_keywords/openvpn
RUN emerge -v =net-vpn/openvpn-2.6.9
#ENV USE="curl gpg -blksha1 -cgi -cvs -doc -highlight -iconv -keyring -mediawiki -nls -pcre -perforce -perl -safe-directory (-selinux) -subversion -test -tk -webdav -xinetd"
#RUN emerge -v dev-vcs/git dev-build/make
WORKDIR /tmp/openvpn
RUN mkdir -p lib64 usr/bin etc/openvpn{client,server} etc/systemd/system tmp
RUN cp -v   /lib64/ld-linux-x86-64.so.2                                              -t lib64
RUN ldd /usr/bin/openvpn | grep -v 'linux-vdso' |awk '/=>/ {print $3}' | xargs cp -v --copy-contents -t lib64/
RUN ldd /usr/bin/ip | grep -v 'linux-vdso' |awk '/=>/ {print $3}' | xargs cp -v --copy-contents -t lib64/
RUN cp -v /usr/bin/ip usr/bin/ip
RUN cp -v /usr/bin/openvpn usr/bin/openvpn
RUN cp -rfv /lib/systemd/system/openvpn-server@.service /lib/systemd/system/openvpn-client@.service -t etc/systemd/system

#FROM gcc:9.5.0-bullseye AS plugin
FROM ubuntu:16.04 AS plugin
WORKDIR /src
RUN apt-get update -y && apt-get install -y openvpn autoconf re2c libtool libldap2-dev libssl-dev gobjc make gnustep gnustep-devel git
RUN git clone https://github.com/threerings/openvpn-auth-ldap.git openvpn-auth-ldap
WORKDIR /src/openvpn-auth-ldap
RUN git checkout auth-ldap-2.0.4
RUN autoconf && autoheader
RUN ./configure --with-openvpn=/usr/include/openvpn CFLAGS=-fPIC OBJCFLAGS=-std=gnu11 --with-objc-runtime=GNU --prefix=""
RUN make 
RUN make install
RUN mkdir -p /tmp/ldap-auth/lib
WORKDIR /tmp/ldap-auth
RUN cp -rfv /lib/openvpn-auth-ldap.so lib/openvpn-auth-ldap.so
RUN ldd /lib/openvpn-auth-ldap.so | grep -v 'linux-vdso' |awk '/=>/ {print $3}' | xargs cp -v --copy-contents -t lib/

FROM scratch
COPY --from=build /tmp/openvpn /
COPY --from=plugin /tmp/ldap-auth /
#/lib/openvpn-auth-ldap.so
