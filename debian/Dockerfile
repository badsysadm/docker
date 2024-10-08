FROM debian:latest

FROM debian:latest
ENV DEBIAN_FRONTEND=noninteractive
ARG HOSTNAME=devspec01-OpsOS01a
ARG HOSTDOMAIN=devspecops.local
ARG IPV4_WAN
ARG IPV4_WAN_MASK
ARG IPV4_LAN
ARG IPV4_LAN_MASK
ARG NETDEV_WAN=eth0
ARG NETDEV_LAN=eth1
ARG DNS="8.8.8.8 8.8.4.4"
ARG NTP="ntp1.selectel.org ntp2.selectel.org"
ARG ROUTE_GATEWAY
ARG ROOT_PASSWORD
RUN apt-get update && apt-get install -y locales linux-image-amd64 mdadm curl wget nano iputils-ping iproute2 openssh-server htop btop lsb-release psmisc sudo gnupg2 apt-transport-https mc 
COPY authorized_keys /root/.ssh/authorized_keys
COPY sshd_config /etc/ssh/sshd_config
RUN chmod 0600 -R /root/.ssh
RUN echo "\
/dev/md0       /boot   ext2    defaults,noatime        0 1 \n\
/dev/md1       /       ext4    defaults,noatime        0 0 \n\
" > /etc/fstab
RUN echo "\
0.0 0 0.0 \n\
0 \n\
UTC \n\
" > /etc/adjtime
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen
RUN mount > /tmp_out
RUN apt-get install -y grub-efi efibootmgr systemd systemd-resolved systemd-container systemd-userdbd libnss-systemd systemd-homed 
RUN grub-install /dev/sda --target=x86_64-efi
RUN update-grub
RUN ln -s /lib/systemd/systemd /sbin/init || true
RUN ln -s /lib/systemd/system/systemd-networkd.service /etc/systemd/system/multi-user.target.wants/systemd-networkd.service
RUN ln -s /lib/systemd/system/systemd-resolved.service /etc/systemd/system/multi-user.target.wants/systemd-resolved.service
RUN ln -s /lib/systemd/system/systemd-timesyncd.service /etc/systemd/system/multi-user.target.wants/systemd-timesyncd.service
RUN echo "$HOSTNAME" > /etc/hostname
RUN echo "\
passwd:         files systemd \n\
group:          files [SUCCESS=merge] systemd \n\
shadow:         files systemd \n\
gshadow:        files systemd \n\
\n\
hosts:          files myhostname mymachines resolve [!UNAVAIL=return] dns \n\
networks:       files \n\
\n\
protocols:      db files \n\
services:       db files \n\
ethers:         db files \n\
rpc:            db files \n\
\n\
netgroup:       nis \n\
" > /etc/nsswitch.conf
RUN echo "\
127.0.0.1  localhost \n\
$IPV4_LAN  $HOSTNAME $HOSTNAME.$HOSTDOMAIN \n\
" > /etc/hosts
RUN curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/debian/12/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/12/amd64/latest bookworm main" | tee /etc/apt/sources.list.d/salt.list
RUN apt-get update && apt-get install --no-install-recommends -y salt-minion
RUN rm -rfv /etc/systemd/system/multi-user.target.wants/salt-minion.service
RUN codename=$(lsb_release -cs);echo "deb http://deb.debian.org/debian $codename-backports main contrib non-free"|tee -a /etc/apt/sources.list && apt update
RUN apt install -y linux-headers-amd64 && apt install -y -t stable-backports zfsutils-linux
RUN echo "$ROOT_PASSWORD\n$ROOT_PASSWORD" | (passwd root) || true
RUN echo $ROOT_PASSWORD > /root/.pass
RUN echo "\
[Resolve] \n\
DNS=$DNS \n\
#FallbackDNS= \n\
#Domains= \n\
LLMNR=no \n\
MulticastDNS=no \n\
DNSSEC=allow-downgrade \n\
DNSOverTLS=no \n\
Cache=yes \n\
DNSStubListener=no \n\
ReadEtcHosts=yes \n\
#ResolveUnicastSingleLabel=no \n\
" > /etc/systemd/resolved.conf
RUN echo "\
[Time] \n\
NTP=$NTP \n\
FallbackNTP= \n\
#RootDistanceMaxSec=5 \n\
#PollIntervalMinSec=32 \n\
#PollIntervalMaxSec=2048 \n\
" > /etc/systemd/timesyncd.conf
RUN echo "\
[Match] \n\
Name=$NETDEV_WAN \n\
\n\
[Network] \n\
Address=$IPV4_WAN/$IPV4_WAN_MASK \n\
Gateway=$ROUTE_GATEWAY \n\
IPv6AcceptRA=no \n\
LinkLocalAddressing=no \n\
LLDP=no \n\
" > /etc/systemd/network/wan.network
RUN echo "\
[Match] \n\
Name=$NETDEV_LAN \n\
\n\
[Network] \n\
Address=$IPV4_LAN/$IPV4_LAN_MASK \n\
IPv6AcceptRA=no \n\
LinkLocalAddressing=no \n\
LLDP=no \n\
" > /etc/systemd/network/lan.network
RUN echo "\
net.ipv6.conf.all.disable_ipv6 = 1 \n\
net.ipv6.conf.default.disable_ipv6 = 1 \n\
net.ipv6.conf.lo.disable_ipv6 = 1 \n\
" > /etc/sysctl.conf
RUN echo "\
rm -rfv /etc/resolv.conf && ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf  \n\
zpool create ssd mirror \n\
zfs create -o mountpoint=/data ssd/data \n\
" > /root/.install
