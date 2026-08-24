FROM 127.0.0.1:12670/distro/debian:trixie AS build

ENV SYSTEMD_STUB_BIN="/src/boot/efi/linuxx64.efi.stub"
ENV CMDLINE="console=ttyS0 rw selinux=0 rdinit=/usr/lib/systemd/systemd init=/init systemd.unit=default.target "
#ENV CMDLINE="console=ttyS0 rw selinux=1 rdinit=/usr/local/bin/sh systemd.unit=default.target"
ENV CMDLINE_MAIN="${CMDLINE} loglevel=1"
ENV CMDLINE_DEBUG="${CMDLINE} systemd.log_level=debug systemd.log_target=console"
ENV KVER="6.12.101+deb13-amd64"
ENV KERNEL_BIN="/boot/vmlinuz-${KVER}"
ENV INITRD_TARGET="/src/initrd.img"
ENV UKI_OUT="/src/custom.EFI"
ENV OVMF=/usr/share/ovmf/OVMF.fd

WORKDIR /src/target
RUN bash -c 'mkdir -p {etc,dev,proc,sys,run,root,var/log,tmp,usr/{bin,sbin,lib,lib64}}'
RUN ln -s usr/bin bin && \
    ln -s usr/sbin sbin && \
    ln -s usr/lib lib && \
    ln -s usr/lib64 lib64
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
    ln -sf /usr/lib/systemd/system/getty.target getty.target

WORKDIR /src/target/etc
RUN echo "root:x:0:0:root:/root:/usr/local/bin/sh" > "passwd"
RUN echo "root:x:0:" > "group"
RUN echo "root::19000:0:99999:7:::" > "shadow"
RUN chmod 600 "shadow"

RUN touch "/src/target/var/log/services.log" "/src/target/var/log/kernel.log"
RUN chmod 666 "/src/target/var/log/services.log" "/src/target/var/log/kernel.log"

#FROM scratch AS initrd
#COPY --from=build /src/target/ /
COPY --from=127.0.0.1:12670/pkg/utils/busybox:1.37.0 /usr/bin/* /src/target/usr/local/bin/

COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 \
    /sbin/ldconfig \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 \
    /lib64/ld-linux-x86-64.so.2 \
    /lib64/libc.so.6 \
    /lib64/libm.so.6 \
    /lib64/libnss_files.so.2 \
    /src/target/usr/lib64/
#COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 /lib64/libc.so.6 /lib64/libm.so.6  /usr/lib64/
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 /sbin/agetty /src/target/usr/sbin/agetty
COPY --from=127.0.0.1:12670/pkg/utils/util-linux:2.42.2 \
    /bin/login \
    /bin/kill \
    /sbin/agetty \
    /sbin/mkfs \
    /sbin/mkswap \
    /sbin/nologin \
    /sbin/pivot_root \
    /sbin/swapon \
    /sbin/swapoff \
    /sbin/switch_root \
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
    /src/target/usr/lib64/

COPY --from=127.0.0.1:12670/pkg/utils/coreutils:9.5 \
    /usr/bin/coreutils \
    /src/target/usr/bin/
COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/systemd/systemd \
    /usr/lib/systemd/systemd-executor \
    /usr/lib/systemd/systemd-udevd  \
    /usr/lib/systemd/systemd-sulogin-shell \
    /src/target/usr/lib/systemd/

COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
    ${SYSTEMD_STUB_BIN}

COPY --from=127.0.0.1:12670/pkg/system/systemd:261 \
    /usr/bin/systemd-machine-id-setup \
    /usr/bin/systemctl \
    /usr/bin/udevadm \
    /usr/bin/systemd-tty-ask-password-agent \
    /src/target/usr/bin/
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

#COPY getty-serial@.service /src/target/usr/lib/systemd/system/serial-getty@.service

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    systemd-ukify systemd-boot cpio gzip linux-image-amd64 ovmf > /dev/null

#RUN touch /src/target/etc/initrd-release
RUN touch /src/target/etc/fstab
#/src/target/etc/initrd-release
RUN ln -sf usr/lib/systemd/systemd /src/target/init

WORKDIR /src/target
RUN mkdir -p usr/lib/modules/${KVER}
RUN cp -r /lib/modules/${KVER} usr/lib/modules/
RUN depmod -b /src/target ${KVER}
RUN find . | cpio -H newc -o | gzip -9 > "${INITRD_TARGET}"
WORKDIR /src
RUN ukify build --stub "${SYSTEMD_STUB_BIN}" --linux "${KERNEL_BIN}" --initrd "${INITRD_TARGET}" --cmdline "${CMDLINE_MAIN}" --output "${UKI_OUT}"

#SYSTEMD_STUB_BIN
