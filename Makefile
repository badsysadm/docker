PHONY: util-linux

REGISTRY_BADSYSADM := oci.badsysadm.local:80
KANIKO_IMAGE_GOOGLE := gcr.io/kaniko-project/executor:latest oci:.build/oci-bundle:latest
KANIKO_IMAGE_GITLAB := registry.gitlab.com/gitlab-ci-utils/container-images/kaniko:v1.25.16-debug
KANIKO_IMAGE_LOCAL := 127.0.0.1:12670/system/kaniko:v1.25.16
KANIKO_IMAGE_BADSYSADM := $(REGISTRY_BADSYSADM)/system/kaniko:v1.25.16
KANIKO_IMAGE := $(KANIKO_IMAGE_BADSYSADM)
SKOPEO_CMD := skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci

FORCE:

glibc binutils: section = system
glibc: version ?= 2.44

dialog coreutils: section = usr
dialog: version ?= 1.3-20260721
coreutils: version ?= 9.5

findutils iputils xzutils util-linux: section = utils
findutils: version ?= 4.11.0
iputils: version ?= 20250605
xzutils: version ?= 5.6.2
util-linux: version ?= 2.42.2

busybox: section = tools

include mk/core.mk
include mk/bs.mk
