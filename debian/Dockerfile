FROM debian:latest

FROM debian:latest
ENV DEBIAN_FRONTEND=noninteractive
ARG HOSTNAME=devspec01-OpsOS01a
ARG HOSTDOMAIN=devspecops.local
ARG IPV4_WAN
ARG IPV4_LAN
ARG NETDEV_WAN=eth0
ARG NETDEV_LAN=eth1
ARG DNS="8.8.8.8 8.8.4.4"
ARG ROUTE_GATEWAY
#RUN apt-get update && apt-get install -y mc apt-transport-https ca-certificates curl gnupg2 software-properties-common \
#                                         sudo openssl wget psmisc net-tools python3 python3-pip bash-completion jq ethtool ssh locales linux-image-amd64 tcpdump vim nano
COPY authorized_keys /root/.ssh/authorized_keys
COPY sshd_config /etc/ssh/sshd_config
RUN chmod 0600 -R /root/.ssh
COPY fstab /etc/fstab
RUN echo -e "\
0.0 0 0.0 \n\
0 \n\
UTC \n\
" > /etc/adjtime
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen
RUN mount
RUN apt-get install -y grub-pc
RUN grub-install /dev/sda
RUN update-grub
