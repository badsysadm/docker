FROM debian:trixie-20240211-slim AS build
WORKDIR /src
RUN apt-get update && apt-get install -y git autoconf pkg-config libssl-dev make python3 pandoc > /dev/null
RUN apt-get install -y libtool libevent-dev libsystemd-dev libpam-dev libldap-dev > /dev/null
#ARG PGBOUNCER_REPO=https://github.com/pgbouncer/pgbouncer.git
ARG PGBOUNCER_REPO=https://github.com/zhaorui20005/pgbouncer-postgres.git
ARG PGBOUNCER_BRANCH=zhaorui_ldap_for_upstream
RUN git clone -b $PGBOUNCER_BRANCH  $PGBOUNCER_REPO pgbouncer

WORKDIR /src/pgbouncer
#ARG PGBOUNCER_BRANCH=master
RUN git checkout $PGBOUNCER_BRANCH
RUN git submodule init && git submodule update
RUN ./autogen.sh
RUN ./configure --with-pam --with-systemd --with-ldap=yes --prefix="" --sysconfdir="/etc/pgbouncer/"
RUN make
RUN make install
#RUN touch userlist.txt
RUN echo "postgres:x:1000:1000:pgbouncer,,,:/var/lib/pgbouncer:/bin/false" > passwd && chown 1000 ./passwd
RUN mkdir -p /src/lib
RUN ldd /bin/pgbouncer  | awk '/=>/ {print $3}' | xargs cp -v --copy-contents   -t /src/lib

FROM scratch
COPY --from=build --chown=1000 --chmod=777 /tmp /tmp
COPY --from=build /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/
COPY --from=build /src/lib/* /lib/
#COPY --from=build /lib/x86_64-linux-gnu/libevent-2.1.so.7  /lib/x86_64-linux-gnu/libevent-2.1.so.7.0.1  \
#                  /lib/x86_64-linux-gnu/libssl.so.3                                                     \
#                  /lib/x86_64-linux-gnu/libcrypto.so.3                                                  \
#                  /lib/x86_64-linux-gnu/libsystemd.so.0    /lib/x86_64-linux-gnu/libsystemd.so.0.38.0   \
#                  /lib/x86_64-linux-gnu/libpam.so.0        /lib/x86_64-linux-gnu/libpam.so.0.85.1       \
#                  /lib/x86_64-linux-gnu/libc.so.6                                                       \
#                  /lib/x86_64-linux-gnu/libcap.so.2        /lib/x86_64-linux-gnu/libcap.so.2.66         \
#                  /lib/x86_64-linux-gnu/libgcrypt.so.20    /lib/x86_64-linux-gnu/libgcrypt.so.20.4.3    \
#                  /lib/x86_64-linux-gnu/liblz4.so.1        /lib/x86_64-linux-gnu/liblz4.so.1.9.4        \
#                  /lib/x86_64-linux-gnu/liblzma.so.5       /lib/x86_64-linux-gnu/liblzma.so.5.4.5       \
#                  /lib/x86_64-linux-gnu/libzstd.so.1       /lib/x86_64-linux-gnu/libzstd.so.1.5.5       \
#                  /lib/x86_64-linux-gnu/libaudit.so.1      /lib/x86_64-linux-gnu/libaudit.so.1.0.0      \
#                  /lib/x86_64-linux-gnu/libgpg-error.so.0  /lib/x86_64-linux-gnu/libgpg-error.so.0.34.0 \
#                  /lib/x86_64-linux-gnu/libcap-ng.so.0     /lib/x86_64-linux-gnu/libcap-ng.so.0.0.0     \
#                  /lib/
#COPY --from=build /share/doc/pgbouncer/pgbouncer-minimal.ini /etc/pgbouncer/pgbouncer.ini
#COPY --from=build /src/pgbouncer/userlist.txt /etc/pgbouncer/userlist.txt
COPY --from=build /src/pgbouncer/passwd /etc/passwd
COPY --from=build /usr/lib/os-release /etc/os-release
#COPY --from=build /share/doc/pgbouncer/pgbouncer.service /share/doc/pgbouncer/pgbouncer.socket /etc/systemd/system/
USER postgres
COPY --from=build /bin/pgbouncer /usr/bin/pgbouncer
