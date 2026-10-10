.PHONY: util-linux

REGISTRY_BADSYSADM := oci.badsysadm.local:80
KANIKO_IMAGE_GOOGLE := gcr.io/kaniko-project/executor:latest oci:.build/oci-bundle:latest
KANIKO_IMAGE_GITLAB := registry.gitlab.com/gitlab-ci-utils/container-images/kaniko:v1.25.16-debug
KANIKO_IMAGE_LOCAL := 127.0.0.1:12670/system/kaniko:v1.25.16
KANIKO_IMAGE_BADSYSADM := $(REGISTRY_BADSYSADM)/system/kaniko:v1.25.16
KANIKO_IMAGE := $(KANIKO_IMAGE_BADSYSADM)
SKOPEO_CMD := skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci

FORCE:

glibc dpkg apt openssh kmod systemd grub pam sudo: section = system
glibc: version ?= 2.44
dpkg: version ?= 1.22.11
apt: version ?= 3.3.3
openssh: version ?= 10.5p1
kmod: version ?= 34.2
systemd: version ?= 261
grub: version ?= 2.14
pam: version ?= 1.7.2
sudo: version ?= 1.9.17p2

libnftnl ncurses: section = lib
libnftnl: version ?= 1.3.2
ncurses: version ?= 6.6

nftables iproute2: section = net
nftables: version ?= 1.1.7
iproute2: version ?= 7.2.0

mailutils: section = utils
mailutils: version ?= 3.21

bash dialog kbd: section = usr
bash: version ?= 5.3
dialog: version ?= 1.3-20260721
coreutils: version ?= 9.5
kbd: version ?= 2.10.0

findutils diffutils iputils xzutils util-linux tar sed gawk strace coreutils wipe dump net-tools elfutils binutils procps: section = utils
findutils: version ?= 4.11.0
diffutils: version ?= 3.12
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
acl: version ?= 2.4.0

gnupg openssl krb5 aide acl: section = security
gnupg: version ?= 2.4.7
openssl: version ?= 3.6.5
krb5: version ?= 1.22.2
aide: version ?= 0.19.4

include mk/core.mk
include mk/bs.mk
