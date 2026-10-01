FROM 127.0.0.1:12670/distro/debian:trixie AS build

ENV SYSTEMD_STUB_BIN="/src/boot/efi/linuxx64.efi.stub"
ENV CMDLINE="console=ttyS0 rw selinux=0 rdinit=/usr/lib/systemd/systemd init=/init systemd.unit=default.target "
#ENV CMDLINE="console=ttyS0 rw selinux=1 rdinit=/usr/local/bin/sh systemd.unit=default.target"
ENV CMDLINE_MAIN="${CMDLINE} loglevel=1"
ENV CMDLINE_DEBUG="${CMDLINE} systemd.log_level=debug systemd.log_target=console"
ENV KVER="6.12.107+deb13-amd64"
ENV KERNEL_BIN="/boot/vmlinuz-${KVER}"
ENV INITRD_TARGET="/src/initrd.img"
ENV UKI_OUT="/src/custom.EFI"
ENV OVMF=/usr/share/ovmf/OVMF.fd

WORKDIR /src/target
RUN bash -c 'mkdir -p {etc,dev,proc,sys,run,root,var/log,tmp,usr/{bin,sbin,lib,lib64}}'
RUN ln -s usr/bin bin && \
    ln -s usr/sbin sbin && \
    ln -s usr/lib lib && \
    ln -s usr/lib64 lib64 && \
    ln -sf /run var/run
WORKDIR /src/target/usr/bin
RUN ln -s coreutils [ && \
    ln -s coreutils ] && \
    ln -s coreutils cat && \
    ln -s coreutils touch && \
    ln -s coreutils tail && \
    ln -s coreutils cp && \
    ln -s coreutils mkdir && \
    ln -s coreutils rm && \
    ln -s coreutils ls
WORKDIR /src/target/usr/lib/systemd/system
RUN ln -s multi-user.target default.target
WORKDIR /src/target/etc/systemd/system/getty.target.wants
RUN ln -s /usr/lib/systemd/system/serial-getty@.service getty@ttyS0.service
WORKDIR /src/target/etc/systemd/system/default.target.wants
RUN ln -sf /usr/lib/systemd/system/systemd-udevd.service systemd-udevd.service && \
    ln -sf /usr/lib/systemd/system/systemd-udev-trigger.service systemd-udev-trigger.service && \
    ln -sf /usr/lib/systemd/system/klogd.service klogd.service && \
    ln -sf /usr/lib/systemd/system/getty.target getty.target && \
    ln -sf /usr/lib/systemd/system/systemd-sysusers.service systemd-sysusers.service && \
    ln -sf /usr/lib/systemd/system/systemd-tmpfiles-setup.service systemd-tmpfiles-setup.service && \
    ln -sf /usr/lib/systemd/system/systemd-localed.service systemd-localed.service && \
    ln -sf /usr/lib/systemd/system/systemd-timedated systemd-timedated.service && \
    ln -sf /usr/lib/systemd/system/systemd-hostnamed systemd-hostnamed.service && \
    ln -sf /usr/lib/systemd/system/systemd-modules-load.service systemd-modules-load.service

WORKDIR /src/target/etc
RUN echo "root:x:0:0:root:/root:/usr/bin/bash" > "passwd" && \
    echo "systemd-network:x:998:998:systemd Network Management:/:/usr/sbin/nologin" >> "passwd" && \
    echo "systemd-resolve:x:990:990:systemd Resolver:/:/usr/sbin/nologin" >> "passwd" && \
    echo "systemd-timesync:x:988:988:systemd Time Synchronization:/:/usr/sbin/nologin" >> "passwd"
RUN echo "root:x:0:" > "group" && \
    echo "systemd-network:x:998:" >> "group" && \
    echo "systemd-resolve:x:990:" >> "group" && \
    echo "systemd-timesync:x:988" >> "group"
RUN echo "root::19000:0:99999:7:::" > "shadow" && \
    echo "systemd-network:!*:20444:::::1:" >> "shadow" && \
    echo "systemd-resolve:!*:20444:::::1:" >> "shadow" && \
    echo "systemd-timesync:!*:20465:::::1:" >> "shadow"
RUN chmod 600 "shadow"

RUN touch "/src/target/var/log/services.log" "/src/target/var/log/kernel.log"
RUN chmod 666 "/src/target/var/log/services.log" "/src/target/var/log/kernel.log"

COPY --from=127.0.0.1:12670/pkg/utils/busybox:1.37.0 /usr/bin/* /src/target/usr/local/bin/

COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 \
    /sbin/ldconfig \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 \
    /usr/lib/locale \
    /src/target/usr/lib/locale
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 \
    /lib64/ld-linux-x86-64.so.2 \
    /lib64/libc.so.6 \
    /lib64/libm.so.6 \
    /lib64/libnss_files.so.2 \
    /src/target/usr/lib64/
COPY --from=127.0.0.1:12670/pkg/utils/bash:5.3 \
    /bin/bash \
    /src/target/usr/bin/bash

COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /sbin/agetty \
    /sbin/nologin \
    /sbin/mkfs \
    /sbin/mkswap \
    /sbin/pivot_root \
    /sbin/swapon \
    /sbin/swapoff \
    /sbin/switch_root \
    /src/target/usr/sbin/
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /bin/login \
    /bin/kill \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /bin/losetup.static /src/target/usr/bin/losetup
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /bin/mount.static /src/target/usr/bin/mount
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /bin/umount.static /src/target/usr/bin/umount
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /sbin/fdisk.static /src/target/usr/bin/fdisk
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /lib/libmount.so.1 \
    /lib/libmount.so.1.1.0 \
    /lib/libblkid.so.1 \
    /lib/libblkid.so.1.1.0 \
    /lib/libuuid.so.1 \
    /lib/libuuid.so.1.3.0 \
    /lib/libfdisk.so.1 \
    /lib/libfdisk.so.1.1.0 \
    /src/target/usr/lib64/

COPY --from=127.0.0.1:12670/pkg/utils/coreutils:9.5 \
    /usr/bin/coreutils \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/systemd/systemd \
    /usr/lib/systemd/systemd-executor \
    /usr/lib/systemd/systemd-udevd  \
    /usr/lib/systemd/systemd-sulogin-shell \
    /usr/lib/systemd/systemd-hostnamed \
    /usr/lib/systemd/systemd-import \
    /usr/lib/systemd/systemd-importd \
    /usr/lib/systemd/systemd-localed \
    /usr/lib/systemd/systemd-makefs \
    /usr/lib/systemd/systemd-modules-load \
    /usr/lib/systemd/systemd-networkd \
    /usr/lib/systemd/systemd-networkd-wait-online \
    /usr/lib/systemd/systemd-network-generator \
    /usr/lib/systemd/systemd-pull \
    /usr/lib/systemd/systemd-resolved \
    /usr/lib/systemd/systemd-sysctl \
    /usr/lib/systemd/systemd-timedated \
    /usr/lib/systemd/systemd-timesyncd \
    /usr/lib/systemd/systemd-time-wait-sync \
    /usr/lib/systemd/system-shutdown \
    /usr/lib/systemd/systemd-hostnamed \
    /usr/lib/systemd/systemd-modules-load \
    /usr/lib/systemd/systemd-vconsole-setup \
    /src/target/usr/lib/systemd/
#systemd-shutdown.standalone
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
    ${SYSTEMD_STUB_BIN}
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/share/dbus-1 \
    /src/target/usr/share/dbus-1
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/udev/rules.d/ \
    /src/target/usr/lib/udev/rules.d/

COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/bin/systemd-machine-id-setup \
    /usr/bin/systemctl \
    /usr/bin/udevadm \
    /usr/bin/systemd-tty-ask-password-agent \
    /usr/bin/bootctl \
    /usr/bin/hostnamectl \
    /usr/bin/importctl \
    /usr/bin/kernel-install \
    /usr/bin/localectl \
    /usr/bin/networkctl \
    /usr/bin/resolvectl \
    /usr/bin/systemd-firstboot \
    /usr/bin/systemd-id128 \
    /usr/bin/systemd-machine-id-setup \
    /usr/bin/systemd-mount \
    /usr/bin/systemd-mstack \
    /usr/bin/systemd-run \
    /usr/bin/systemd-umount \
    /usr/bin/systemd-sysusers \
    /usr/bin/timedatectl \
    /usr/bin/ukify \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/bin/systemd-repart.standalone \
    /src/target/usr/bin/systemd-repart
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/bin/systemd-tmpfiles.standalone \
    /src/target/usr/bin/systemd-tmpfiles
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
    /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
    /src/target/usr/lib/systemd/boot/efi/
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/x86_64-linux-gnu/systemd/ \
    /src/target/usr/lib64/
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/systemd/system/emergency.target \
    /usr/lib/systemd/system/emergency.service \
    /usr/lib/systemd/system/basic.target \
    /usr/lib/systemd/system/sysinit.target \
    /usr/lib/systemd/system/shutdown.target \
    /usr/lib/systemd/system/local-fs.target \
    /usr/lib/systemd/system/swap.target \
    /usr/lib/systemd/system/multi-user.target \
    /usr/lib/systemd/system/paths.target \
    /usr/lib/systemd/system/slices.target \
    /usr/lib/systemd/system/sockets.target \
    /usr/lib/systemd/system/timers.target \
    /usr/lib/systemd/system/time-sync.target \
    /usr/lib/systemd/system/time-set.target \
    /usr/lib/systemd/system/systemd-udevd.service \
    /usr/lib/systemd/system/systemd-udevd-control.socket \
    /usr/lib/systemd/system/systemd-udevd-kernel.socket \
    /usr/lib/systemd/system/systemd-udev-trigger.service \
    /usr/lib/systemd/system/systemd-udev-settle.service \
    /usr/lib/systemd/system/serial-getty@.service \
    /usr/lib/systemd/system/getty@.service \
    /usr/lib/systemd/system/getty.target \
    /usr/lib/systemd/system/getty-pre.target \
    /usr/lib/systemd/system/systemd-udevd.service \
    /usr/lib/systemd/system/systemd-udev-trigger.service \
    /usr/lib/systemd/system/systemd-hostnamed.service \
    /usr/lib/systemd/system/systemd-hostnamed.socket \
    /usr/lib/systemd/system/systemd-importd.service \
    /usr/lib/systemd/system/systemd-importd.socket \
    /usr/lib/systemd/system/systemd-localed.service \
    /usr/lib/systemd/system/systemd-networkd.service \
    /usr/lib/systemd/system/systemd-networkd-persistent-storage.service \
    /usr/lib/systemd/system/systemd-networkd-resolve-hook.socket \
    /usr/lib/systemd/system/systemd-networkd.socket \
    /usr/lib/systemd/system/systemd-networkd-wait-online.service \
    /usr/lib/systemd/system/systemd-networkd-wait-online@.service \
    /usr/lib/systemd/system/systemd-networkd-varlink.socket \
    /usr/lib/systemd/system/systemd-networkd-varlink-metrics.socket \
    /usr/lib/systemd/system/systemd-network-generator.service \
    /usr/lib/systemd/system/systemd-networkd-persistent-storage.service \
    /usr/lib/systemd/system/network-online.target \
    /usr/lib/systemd/system/systemd-repart.service \
    /usr/lib/systemd/system/systemd-repart@.service \
    /usr/lib/systemd/system/systemd-repart.socket \
    /usr/lib/systemd/system/systemd-resolved.service \
    /usr/lib/systemd/system/systemd-resolved-varlink.socket \
    /usr/lib/systemd/system/systemd-resolved-monitor.socket \
    /usr/lib/systemd/system/systemd-sysusers.service \
    /usr/lib/systemd/system/systemd-timedated.service \
    /usr/lib/systemd/system/systemd-timesyncd.service \
    /usr/lib/systemd/system/systemd-time-wait-sync.service \
    /usr/lib/systemd/system/systemd-tmpfiles-clean.service \
    /usr/lib/systemd/system/systemd-tmpfiles-clean.timer \
    /usr/lib/systemd/system/systemd-tmpfiles-setup-dev-early.service \
    /usr/lib/systemd/system/systemd-tmpfiles-setup-dev.service \
    /usr/lib/systemd/system/systemd-tmpfiles-setup.service \
    /usr/lib/systemd/system/systemd-hostnamed.service \
    /usr/lib/systemd/system/systemd-modules-load.service \
    /usr/lib/systemd/system/systemd-vconsole-setup.service \
    /usr/lib/systemd/system/tmp.mount \
    /usr/lib/systemd/system/dbus-org.freedesktop.hostname1.service \
    /usr/lib/systemd/system/dbus-org.freedesktop.locale1.service \
    /usr/lib/systemd/system/dbus-org.freedesktop.login1.service \
    /usr/lib/systemd/system/dbus-org.freedesktop.timedate1.service \
    /src/target/usr/lib/systemd/system/
COPY --from=127.0.0.1:12670/pkg/system/pam:1.7.2 \
    /usr/lib64/libpam.so \
    /usr/lib64/libpam.so.0 \
    /usr/lib64/libpam.so.0.85.1 \
    /usr/lib64/libpam_misc.so \
    /usr/lib64/libpam_misc.so.0 \
    /usr/lib64/libpam_misc.so.0.82.1 \
    /src/target/usr/lib64/
COPY --from=127.0.0.1:12670/pkg/system/pam:1.7.2 \
    /usr/lib64/security/ \
    /src/target/usr/lib64/security/
COPY --from=127.0.0.1:12670/pkg/system/pam:1.7.2 \
    /etc/security \
    /src/target/etc/
COPY pam.login.conf /src/target/etc/pam.d/login
COPY nsswitch.conf /src/target/etc/nsswitch.conf
COPY system.conf /src/target/etc/systemd/system.conf
COPY klog.service /src/target/etc/systemd/system/klogd.service

COPY --from=127.0.0.1:12670/pkg/system/dbus:1.16.2 \
    /usr/bin/dbus-daemon \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/system/dbus:1.16.2 \
     /lib/systemd/system \
     /src/target/usr/lib/systemd/system
COPY --from=127.0.0.1:12670/pkg/system/dbus:1.16.2 \
     /usr/share/dbus-1 \
     /src/target/usr/share/dbus-1
COPY --from=127.0.0.1:12670/pkg/system/dbus:1.16.2 \
    /usr/lib/sysusers.d/dbus.conf \
    /src/target/usr/lib/sysusers.d/

COPY --from=127.0.0.1:12670/pkg/system/dbus:1.16.2 \
    /usr/lib/tmpfiles.d/dbus.conf \
    /src/target/usr/lib/tmpfiles.d/

COPY --from=127.0.0.1:12670/pkg/system/kmod:34.2 \
    /bin \
    /src/target/usr/bin
COPY --from=127.0.0.1:12670/pkg/system/kmod:34.2 \
    /lib/x86_64-linux-gnu/libkmod.so \
    /lib/x86_64-linux-gnu/libkmod.so.2 \
    /lib/x86_64-linux-gnu/libkmod.so.2.5.1 \
    /src/target/usr/lib64/

COPY --from=127.0.0.1:12670/pkg/utils/dialog:1.3-20260721 \
    /bin/dialog \
    /src/target/usr/bin/


COPY --from=127.0.0.1:12670/pkg/libs/ncurses:6.6 /usr/share/terminfo/l/linux /src/target/usr/share/terminfo/l/
COPY --from=127.0.0.1:12670/pkg/libs/ncurses:6.6 /usr/share/terminfo/x/xterm /src/target/usr/share/terminfo/x/
COPY --from=127.0.0.1:12670/pkg/libs/ncurses:6.6 /usr/share/terminfo/v/vt220 /src/target/usr/share/terminfo/v/
COPY --from=127.0.0.1:12670/pkg/libs/ncurses:6.6 /usr/share/terminfo/a/ansi  /src/target/usr/share/terminfo/a/

COPY dialogrc /src/target/etc/dialogrc
COPY bashrc /src/target/etc/bash.bashrc
COPY locale.conf /src/target/etc/locale.conf
COPY profile /src/target/etc/profile
COPY inputrc /src/target/etc/inputrc
COPY vconsole.conf /src/target/etc/vconsole.conf
COPY modules.conf /src/target/usr/lib/modules-load.d/modules.conf

COPY --from=127.0.0.1:12670/pkg/libs/openssl:3.6.4 \
    /usr/lib/x86_64-linux-gnu/libcrypto.so \
    /usr/lib/x86_64-linux-gnu/libcrypto.so.3 \
    /usr/lib/x86_64-linux-gnu/libssl.so \
    /usr/lib/x86_64-linux-gnu/libssl.so.3 \
    /src/target/usr/lib64/

COPY --from=127.0.0.1:12670/pkg/system/kbd:2.10.0 \
    /usr/bin/setfont \
    /usr/bin/loadkeys \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/system/kbd:2.10.0 \
    /usr/share/consolefonts/cyr-sun16.psfu \
    /usr/share/consolefonts/UniCyrExt_8x16.psf \
    /src/target/usr/share/consolefonts/
COPY --from=127.0.0.1:12670/pkg/system/kbd:2.10.0 \
    /usr/share/keymaps/i386/qwerty/ru.map \
    /src/target/usr/share/keymaps/i386/qwerty/

COPY --from=127.0.0.1:12670/pkg/utils/nano:9.2 \
    /usr/bin/nano \
    /src/target/usr/bin/nano

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    systemd-ukify systemd-boot cpio gzip linux-image-amd64 ovmf > /dev/null

#RUN touch /src/target/etc/initrd-release
RUN touch /src/target/etc/fstab
RUN ln -sf usr/lib/systemd/systemd /src/target/init

WORKDIR /src/target
RUN mkdir -p usr/lib/modules/${KVER}
RUN cp -r /lib/modules/${KVER} usr/lib/modules/
RUN depmod -b /src/target ${KVER}
RUN find . | cpio -H newc -o | gzip -9 > "${INITRD_TARGET}"
WORKDIR /src
RUN ukify build --stub "${SYSTEMD_STUB_BIN}" --linux "${KERNEL_BIN}" --initrd "${INITRD_TARGET}" --cmdline "${CMDLINE_MAIN}" --output "${UKI_OUT}"
