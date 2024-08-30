FROM debian:latest

FROM debian:latest
ARG HOSTNAME=devspec01-OpsOS01a
ARG HOSTDOMAIN=devspecops.local
ARG IPV4_WAN
ARG IPV4_LAN
ARG NETDEV_WAN=eth0
ARG NETDEV_LAN=eth1
ARG DNS="8.8.8.8 8.8.4.4"
ARG ROUTE_GATEWAY
RUN apt-get update && apt-get install -y tcpdump
COPY authorized_keys /root/.ssh/authorized_keys
COPY sshd_config /etc/ssh/sshd_config
RUN chmod 0600 -R /root/.ssh
