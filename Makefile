.PHONY: kaniko clean bootstrap

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
busybox: section = tools

kaniko:
	mkdir -p .build/oci-bundle .build/rootfs
	skopeo copy --src-tls-verify=false docker://$(KANIKO_IMAGE) oci:.build/oci-bundle:latest
	umoci raw unpack --image .build/oci-bundle .build/rootfs

%Dockerfile: clean kaniko
	mkdir -p "$(shell dirname $(realpath $@))"
	mkdir -p /tmp/cache
	@echo "$(shell dirname $(realpath $@))"
	systemd-run -t \
		-p RootDirectory=$(realpath .build/rootfs/) \
		-p Environment=SSL_CERT_DIR=/kaniko/certs \
		-p BindReadOnlyPaths=/etc/hosts \
		-p BindReadOnlyPaths=/etc/resolv.conf \
		-p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs \
		-p BindReadOnlyPaths=$(realpath $@):/kaniko/Dockerfile.source \
		-p BindReadOnlyPaths=$(shell dirname $(realpath $@)):/kaniko/context \
		 /kaniko/executor --context /kaniko/context  --ignore-path /proc --ignore-path=/sys --ignore-path=/dev -f /kaniko/Dockerfile.source --build-arg VERSION=$(version) --no-push --force --oci-layout-path /kaniko/oci
#	@rm -rf .build/rootfs/kaniko
#--snapshot-mode=time # --single-snapshot --use-new-run
 # --snapshot-mode=redo

version ?=
%:
	@if [ -z "$(version)" ]; then \
		echo "Error: version is not set (use make $@ version=X.XX)"; \
		exit 1; \
	fi
	if ! curl -I --silent -f -k -H "Accept: application/vnd.docker.distribution.manifest.v2+json" $(REGISTRY_BADSYSADM)/v2/src/$(section)/$@/manifests/$(version) >/dev/null 2>&1; then \
		$(MAKE) nell/$(section)/$@/01_src.Dockerfile version=$(version); \
		$(SKOPEO_CMD) docker://$(REGISTRY_BADSYSADM)/src/$(section)/$@:$(version); \
	fi
	if ! curl -I --silent -f -k -H "Accept: application/vnd.docker.distribution.manifest.v2+json" $(REGISTRY_BADSYSADM)/v2/dep/$(section)/$@/manifests/$(version) >/dev/null 2>&1; then \
		$(MAKE) nell/$(section)/$@/02_dep.Dockerfile version=$(version); \
		$(SKOPEO_CMD) docker://$(REGISTRY_BADSYSADM)/dep/$(section)/$@:$(version); \
	fi
	$(MAKE) nell/$(section)/$@/03_bin.Dockerfile version=$(version)
	$(SKOPEO_CMD) docker://$(REGISTRY_BADSYSADM)/bin/$(section)/$@:$(version)

run:
	systemd-run -t \
		-p RootDirectory=$(realpath .build/rootfs/) \
		-p Environment=SSL_CERT_DIR=/kaniko/certs \
		-p BindReadOnlyPaths=/etc/resolv.conf \
		-p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs \
		-p BindReadOnlyPaths=/root/.bashrc:/root/.bashrc \
		/bin/sh

all:
	echo Hello

clean:
	rm -rf .build

bootstrap:
	make bootstrap/debian/bootstrap.Dockerfile
	cp /etc/apt/sources.list .build/rootfs/etc/apt/sources.list.d/
	cp -rf /etc/apt/trusted.gpg.d/* .build/rootfs/etc/apt/trusted.gpg.d/
	systemd-run -t         -p RootDirectory=/root/git/docker/.build/rootfs         -p Environment=SSL_CERT_DIR=/kaniko/certs         -p BindReadOnlyPaths=/etc/resolv.conf         -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs         -p BindReadOnlyPaths=/root/.bashrc:/root/.bashrc  apt update
	systemd-run -t         -p RootDirectory=/root/git/docker/.build/rootfs         -p Environment=SSL_CERT_DIR=/kaniko/certs -p Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin         -p BindReadOnlyPaths=/etc/resolv.conf         -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs         -p BindReadOnlyPaths=/root/.bashrc:/root/.bashrc  apt install gcc-14-base --no-install-recommends
	systemd-run -t         -p RootDirectory=/root/git/docker/.build/rootfs         -p Environment=SSL_CERT_DIR=/kaniko/certs -p Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin         -p BindReadOnlyPaths=/etc/resolv.conf         -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs         -p BindReadOnlyPaths=/root/.bashrc:/root/.bashrc  apt install libc6 --no-install-recommends

qemu:
	$(MAKE) initrd/installer.Dockerfile
	mkdir -p .build
	rm -rf .build/disk.img
	truncate -s 10G .build/disk.img
	$(MAKE) qqemu
qqemu:
	qemu-system-x86_64 -enable-kvm -m 2G \
	  -bios .build/rootfs/usr/share/ovmf/OVMF.fd \
	  -kernel .build/rootfs/src/custom.EFI \
	  -nographic -serial mon:stdio \
	  -device virtio-net-pci,netdev=n1 \
	  -netdev tap,id=n1,ifname=tap0,script=no,downscript=no \
	  -boot menu=on,splash-time=0 \
	  -drive file=.build/disk.img,format=raw,id=hd0,if=none \
	  -device virtio-blk-pci,drive=hd0
