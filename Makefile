REGISTRY_BADSYSADM := oci.badsysadm.local:80
KANIKO_IMAGE_GOOGLE := gcr.io/kaniko-project/executor:latest oci:.build/oci-bundle:latest
KANIKO_IMAGE_GITLAB := registry.gitlab.com/gitlab-ci-utils/container-images/kaniko:v1.25.16-debug
KANIKO_IMAGE_LOCAL := 127.0.0.1:12670/system/kaniko:v1.25.16
KANIKO_IMAGE_BADSYSADM := $(REGISTRY_BADSYSADM)/system/kaniko:v1.25.16
KANIKO_IMAGE := $(KANIKO_IMAGE_BADSYSADM)
SKOPEO_CMD := skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci

FORCE:

git: section = dev
git: version ?= 2.56.0

glibc dpkg apt openssh kmod systemd grub pam sudo logrotate rsyslog dbus shadow: section = system
glibc: version ?= 2.44
dpkg: version ?= 1.22.11
apt: version ?= 3.3.6
openssh: version ?= 10.5p1
kmod: version ?= 34.2
systemd: version ?= 261
grub: version ?= 2.14
pam: version ?= 1.7.2
sudo: version ?= 1.9.17p2
logrotate: version ?= 3.22.0
rsyslog: version ?= 8.2608.0
dbus: version ?= 1.16.2
shadow: version ?= 4.20.3
chrony: version ?= 4.9

libnftnl ncurses glib gnutls zlib libunwind: section = lib
libnftnl: version ?= 1.3.2
ncurses: version ?= 6.6
glib: version ?= 2.84.4
gnutls: version ?= 3.8.13
zlib: version ?= 1.3.1
libunwind: version ?= 1.8.3
zstd: version ?= 1.5.7

nftables iproute2 chrony curl tcpdump ethtool socat: section = net
zot lldap buildbot: section = infra
silo: section = storage
angie radicale calino synapse: section = www
etcd: section = db
skopeo umoci: section = virt
nftables: version ?= 1.1.7
iproute2: version ?= 7.2.0
curl: version ?= 8.23.0
tcpdump: version ?= 4.99.7
ethtool: version ?= 7.2
socat: version ?= 1.8.1.3
zot: version ?= 2.1.23
silo: version ?= 2026-10-26T00-00-00Z
angie: version ?= 1.12.4
radicale: version ?= 3.9.0
calino: version ?= 0.42.0
synapse: version ?= 1.164.2
etcd: version ?= 3.7.3
skopeo: version ?= 1.24.1
umoci: version ?= 0.6.0

mailutils rss2email mcli: section = utils
mailutils: version ?= 3.21
rss2email: version ?= 3.14
mcli: version ?= 2026-10-26T00-00-00Z

bash dialog kbd console-setup nano: section = usr
mc htop: section = tui
bash: version ?= 5.3
dialog: version ?= 1.3-20260721
coreutils: version ?= 9.5
kbd: version ?= 2.10.0
console-setup: version ?= 1.249
nano: version ?= 9.2
mc: version ?= 4.8.33
htop: version ?= 3.5.3

tree zstd findutils diffutils grep jq which pciutils iputils xzutils util-linux tar sed gawk strace coreutils wipe dump net-tools elfutils binutils procps quota: section = utils
tree: version ?= 2.3.2
findutils: version ?= 4.11.0
diffutils: version ?= 3.12
grep: version ?= 3.12
jq: version ?= 1.8.2
which: version ?= 2.25
pciutils: version ?= 3.15.0
iputils: version ?= 20250605
xzutils: version ?= 5.6.2
util-linux: version ?= 2.42.2
tar: version ?= 1.35
sed: version ?= 4.9
gawk: version ?= 5.4.1
strace: version ?= 7.2
wipe: version ?= 0.24
dump: version ?= 0.4b56
net-tools: version ?= 2.10
elfutils: version ?= 0.196
binutils: version ?= 2.47
procps: version ?= 4.0.7
quota: version ?= 4.11
acl: version ?= 2.4.0

gnupg openssl krb5 aide acl polkit apparmor cracklib vault ots trivy cosign ca-certificates audit: section = security
gnupg: version ?= 2.4.7
openssl: version ?= 3.6.5
ca-certificates: version ?= 2026-11-05
krb5: version ?= 1.22.2
aide: version ?= 0.19.4
audit: version ?= 4.2.1
trivy: version ?= 0.76.2
cosign: version ?= 3.1.4
polkit: version ?= 127
apparmor: version ?= 4.1.8
cracklib: version ?= 2.10.3
vault: version ?= 2.2.1
ots: version ?= 1.23.1
lldap: version ?= 0.6.3
buildbot: version ?= 4.3.0

include mk/core.mk
include mk/bs.mk
