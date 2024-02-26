FROM gentoo/stage3:systemd-20240219 AS build
RUN emerge --sync
ENV USE="-cuda -debug -geoip -hardened -lua systemd -test -verify-sig af-packet -af-xdp bpf control-socket detection -hyperscan lz4 nflog nfqueue -redis"
RUN echo -e '\
                  =net-analyzer/suricata-7.0.2 ~amd64 \n\
                  =net-libs/libhtp-0.5.46      ~amd64 \n\
            '> /etc/portage/package.accept_keywords/suricata
RUN emerge -v =net-analyzer/suricata-7.0.2

WORKDIR /tmp/gentoo
RUN mkdir -p etc/suricata          \
             etc/systemd/system    \
             lib64                 \
             usr/lib64             \
             usr/lib               \
             usr/libexec/suricata  \
             usr/bin               \
             var/lib               \
             var/log/suricata      \
             run/suricata

RUN cp -v   /usr/lib/os-release                                                      -t etc
RUN echo 'suricata:!:477:477:User for Suricata IDS:/dev/null:/sbin/nologin'          > etc/passwd
RUN echo 'suricata:x:477:'                                                           > etc/group
RUN cp -rfv /etc/suricata                                                            -t etc
RUN cp -v   /usr/bin/suricata /usr/bin/file                                          -t usr/bin
#RUN cp -v   /usr/bin/suricata                                                        -t usr/bin
#RUN cp -v   /usr/bin/suricatactl                                                     -t usr/bin
#RUN cp -v   /usr/bin/suricatasc                                                      -t usr/bin
#RUN cp -rfv /usr/lib/suricata-update                                                 -t usr/lib
RUN cp -rfv /var/lib/suricata                                                        -t var/lib
RUN cp -rfv /usr/libexec/suricata                                                    -t usr/libexec/suricata
#RUN cp -v   /lib/systemd/system/suricata.service                                     -t etc/systemd/system
RUN cp -v   /lib64/ld-linux-x86-64.so.2                                              -t lib64
RUN ldd /usr/bin/file  | awk '/=>/ {print $3}' | xargs cp -v --copy-contents     -t usr/lib64
RUN ldd /usr/bin/suricata  | awk '/=>/ {print $3}' | xargs cp -vf --copy-contents     -t usr/lib64

COPY suricata.service etc/systemd/system/
COPY suricata.service.override etc/systemd/system/suricata.service.d/override.conf

FROM scratch
COPY --from=build /tmp/gentoo /
COPY --from=build --chown=477:477 /tmp/gentoo/var/log/suricata /var/log/
CMD ["suricata", "--version"]
