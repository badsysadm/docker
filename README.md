# docker
Some Dockerfile for kaniko executor

###Build from kaniko (debian ca cert dir)
```bash
systemd-run -t -p RootDirectory=/root/test/image -p Environment=SSL_CERT_DIR=/kaniko/certs -p BindReadOnlyPaths=/etc/resolv.conf -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs /kaniko/executor --no-push --force --context git://github.com/badsysadm/docker --context-sub-path test --cleanup --tar-path /kaniko/test.tar.gz
```

test
