FROM gentoo/stage3:systemd-20240219 AS build
RUN emerge --sync
ENV USE="dbus systemd -snmp -bfd json regex"
RUN emerge -v =sys-cluster/keepalived-2.2.8

WORKDIR /tmp/gentoo
RUN mkdir -p etc/keepalived      \
             etc/systemd/system  \
             lib64               \
             usr/lib64           \
             usr/bin             \
             run

RUN cp -v   /usr/lib/os-release                                                      -t etc
RUN cp -rfv /etc/keepalived                                                          -t etc
RUN cp -v   /usr/bin/keepalived                                                      -t usr/bin
RUN cp -v   /lib/systemd/system/keepalived.service                                   -t etc/systemd/system
RUN cp -v   /lib64/ld-linux-x86-64.so.2                                              -t lib64
RUN ldd /usr/bin/keepalived  | awk '/=>/ {print $3}' | xargs cp -v --copy-contents   -t usr/lib64

FROM scratch
COPY --from=build tmp/gentoo /
CMD ["keepalived", "-l"]
