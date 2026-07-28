FROM alpine AS build
WORKDIR /src/bootstrap
RUN mkdir -p usr/bin usr/sbin usr/lib usr/lib64 \
             etc/apt/apt.conf.d etc/apt/preferences.d \
             etc/apt/sources.list etc/apt/sources.list.d var/lib/apt/lists/partial \
             etc/apt/trusted.gpg.d/ usr/share/keyrings \
             var/lib/dpkg \
             var/cache/apt/archives/partial \
             var/log/apt
RUN ln -s usr/bin bin && \
    ln -s usr/sbin sbin && \
    ln -s usr/lib lib && \
    ln -s usr/lib64 lib64
WORKDIR /src/bootstrap/usr/bin
RUN ln -s coreutils [ && \
    ln -s coreutils ]

FROM scratch
COPY --from=build /src/bootstrap/ /
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 /sbin/ldconfig /usr/bin/ldconfig
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 /lib64/ld-linux-x86-64.so.2 /usr/lib64/ld-linux-x86-64.so.2
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 /lib64/libc.so.6 /lib64/libm.so.6  /usr/lib64/
COPY --from=127.0.0.1:12670/pkg/utils/dpkg:1.22.11 /usr/bin/dpkg /usr/bin/dpkg-deb /usr/bin/dpkg-split /usr/bin/
COPY --from=127.0.0.1:12670/pkg/utils/dpkg:1.22.11 /usr/bin/dpkg-divert /usr/bin/dpkg-query /usr/bin/dpkg-trigger /usr/bin/update-alternatives /usr/bin/
COPY --from=127.0.0.1:12670/pkg/utils/dpkg:1.22.11 /usr/share/dpkg/cputable /usr/share/dpkg/abitable /usr/share/dpkg/tupletable /usr/share/dpkg/ostable /usr/share/dpkg/
COPY --from=127.0.0.1:12670/pkg/utils/apt:3.3.1 /usr/bin/apt /usr/bin/apt
COPY --from=127.0.0.1:12670/pkg/utils/apt:3.3.1 /usr/lib/apt/methods/http /usr/lib/apt/methods/https /usr/lib/apt/methods/gpgv /usr/lib/apt/methods/store /usr/lib/apt/methods/
COPY --from=127.0.0.1:12670/pkg/utils/gnupg:2.4.7 /usr/bin/gpgv /usr/bin/gpgv
COPY --from=127.0.0.1:12670/pkg/utils/busybox:1.37.0 /usr/bin/* /usr/bin/
COPY --from=127.0.0.1:12670/pkg/utils/tar:1.35  /usr/bin/tar /usr/bin/
COPY --from=127.0.0.1:12670/pkg/utils/xz:5.6.2 /usr/bin/xz /usr/bin/
COPY --from=127.0.0.1:12670/pkg/utils/coreutils:9.5 /usr/bin/coreutils /usr/bin/
