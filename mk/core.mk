.PHONY: kaniko clean bootstrap

LIST_ARTIFACTS := find .build/rootfs/ \( -path .build/rootfs/kaniko -o -path .build/rootfs/etc/hosts -o -path .build/rootfs/etc/resolv.conf \) -prune -o -type f -print0

version ?=

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

check-version:
    @if [ -z "$(version)" ]; then \
        echo "Error: version is not set (use make $@ version=X.XX)"; \
        exit 1; \
    fi

get-src:
    if ! curl -I --silent -f -k -H "Accept: application/vnd.docker.distribution.manifest.v2+json" $(REGISTRY_BADSYSADM)/v2/src/$(section)/$@/manifests/$(version) >/dev/null; then \
        $(MAKE) nell/$(section)/$@/01_src.Dockerfile version=$(version); \
        $(SKOPEO_CMD) docker://$(REGISTRY_BADSYSADM)/src/$(section)/$@:$(version); \
    fi

get-dep:
    if ! curl -I --silent -f -k -H "Accept: application/vnd.docker.distribution.manifest.v2+json" $(REGISTRY_BADSYSADM)/v2/dep/$(section)/$@/manifests/$(version) >/dev/null; then \
        $(MAKE) nell/$(section)/$@/02_dep.Dockerfile version=$(version); \
        $(SKOPEO_CMD) docker://$(REGISTRY_BADSYSADM)/dep/$(section)/$@:$(version); \
    fi

get-build:
    $(MAKE) nell/$(section)/$@/03_bin.Dockerfile version=$(version)
    $(LIST_ARTIFACTS) | xargs -0 sha256sum | sort > .sha256_1

check-reproducibility:
    $(MAKE) nell/$(section)/$@/03_bin.Dockerfile version=$(version)
    $(LIST_ARTIFACTS) | xargs -0 sha256sum | sort > .sha256_2
    diff .sha256_1 .sha256_2

%: check-version get-src get-dep get-build

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
