bootstrap:
	make bootstrap/debian/bootstrap.Dockerfile
	cp /etc/apt/sources.list .build/rootfs/etc/apt/sources.list.d/
	cp -rf /etc/apt/trusted.gpg.d/* .build/rootfs/etc/apt/trusted.gpg.d/
	systemd-run -t         -p RootDirectory=/root/git/docker/.build/rootfs         -p Environment=SSL_CERT_DIR=/kaniko/certs         -p BindReadOnlyPaths=/etc/resolv.conf         -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs         -p BindReadOnlyPaths=/root/.ba>    systemd-run -t         -p RootDirectory=/root/git/docker/.build/rootfs         -p Environment=SSL_CERT_DIR=/kaniko/certs -p Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin         -p BindReadOnlyPaths=/etc/resolv.conf         -p Bind>    systemd-run -t         -p RootDirectory=/root/git/docker/.build/rootfs         -p Environment=SSL_CERT_DIR=/kaniko/certs -p Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin         -p BindReadOnlyPaths=/etc/resolv.conf         -p Bind>

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
