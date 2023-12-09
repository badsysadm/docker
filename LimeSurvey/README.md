```bash
systemd-run -t -p RootDirectory=/root/test/image -p Environment=SSL_CERT_DIR=/kaniko/certs -p BindReadOnlyPaths=/etc/resolv.conf -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs /kaniko/executor --no-push --force --context git://github.com/badsysadm/docker --context-sub-path LimeSurvey --tar-path /kaniko/test.tar.gz
```
