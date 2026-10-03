# docker
Some Dockerfile for kaniko executor

###Build from kaniko (debian ca cert dir)
```bash
systemd-run -t -p RootDirectory=/root/test/image -p Environment=SSL_CERT_DIR=/kaniko/certs -p BindReadOnlyPaths=/etc/resolv.conf -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs /kaniko/executor --no-push --force --context git://github.com/badsysadm/docker --context-sub-path test --cleanup --tar-path /kaniko/test.tar.gz
```

Sign Test



qemu-system-x86_64 -enable-kvm -m 2G -bios .build/rootfs/usr/share/ovmf/OVMF.fd -kernel .build/rootfs/src/custom.EFI -nographic -serial mon:stdio -device virtio-net-pci,netdev=n1 -netdev tap,id=n1,ifname=tap0,script=no,downscript=no -boot menu=on,splash-time=0
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://127.0.0.1:12670/get/source:latest


make nell/perl/01_src.Dockerfile 
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://127.0.0.1:12670/src/perl/perl:5.44.0
make nell/perl/02_dep.Dockerfile 
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://127.0.0.1:12670/dep/perl/perl:5.44.0
make nell/perl/03_bin.Dockerfile 
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://127.0.0.1:12670/bin/perl/perl:5.44.0
make nell/perl/04_deb.Dockerfile 
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://127.0.0.1:12670/deb/perl/perl:5.44.0


# skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci docker://127.0.0.1:12670/pkg/libs/openssl:3.6.5
