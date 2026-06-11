.PHONY: clean

FORCE:

kaniko:
	mkdir -p .build/oci-bundle .build/rootfs
#	skopeo copy docker://omio/gcr.io.kaniko-project.executor:latest oci:.build/oci-bundle:latest
	skopeo copy docker://gcr.io/kaniko-project/executor:latest oci:.build/oci-bundle:latest
	umoci raw unpack --image .build/oci-bundle .build/rootfs

%Dockerfile: clean kaniko
	mkdir -p "$(shell dirname $(realpath $@))"
	mkdir -p /tmp/cache
	@echo "$(shell dirname $(realpath $@))"
	systemd-run -t \
		-p RootDirectory=$(realpath .build/rootfs/) \
		-p Environment=SSL_CERT_DIR=/kaniko/certs \
		-p BindReadOnlyPaths=/etc/resolv.conf \
		-p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs \
		-p BindReadOnlyPaths=$(realpath $@):/kaniko/Dockerfile.source \
		-p BindReadOnlyPaths=$(shell dirname $(realpath $@)):/kaniko/context \
		-p BindPaths=/tmp/cache:/cache \
		 /kaniko/executor --context /kaniko/context -f /kaniko/Dockerfile.source --no-push --force

all:
	echo Hello

clean:
	rm -rf .build
