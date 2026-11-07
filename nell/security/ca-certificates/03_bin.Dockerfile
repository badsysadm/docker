ARG VERSION=20260816

FROM oci.badsysadm.local:80/dep/security/ca-certificates:${VERSION} AS build
ARG VERSION

WORKDIR /src/ca-certificates

RUN make -C mozilla

RUN install -d \
    /usr/share/ca-certificates/mozilla \
    /usr/local/share/ca-certificates \
    /etc/ssl/certs \
    /etc/ca-certificates/update.d

RUN install -m 0644 mozilla/*.crt /usr/share/ca-certificates/mozilla/
RUN install -D -m 0755 sbin/update-ca-certificates /usr/sbin/update-ca-certificates

RUN LC_ALL=C find /usr/share/ca-certificates/mozilla \
    -maxdepth 1 -type f -name '*.crt' -printf 'mozilla/%f\n' | \
    LC_ALL=C sort > /etc/ca-certificates.conf

RUN update-ca-certificates --fresh

RUN install -d \
    /src/target/usr/share/ca-certificates \
    /src/target/usr/local/share \
    /src/target/usr/sbin \
    /src/target/etc/ssl \
    /src/target/etc/ca-certificates

RUN cp -a /usr/share/ca-certificates/mozilla /src/target/usr/share/ca-certificates/
RUN cp -a /usr/local/share/ca-certificates /src/target/usr/local/share/
RUN cp -a /etc/ssl/certs /src/target/etc/ssl/
RUN cp -a /etc/ca-certificates.conf /src/target/etc/
RUN cp -a /etc/ca-certificates/update.d /src/target/etc/ca-certificates/
RUN cp -a /usr/sbin/update-ca-certificates /src/target/usr/sbin/

FROM scratch AS bundle
LABEL org.opencontainers.image.title="ca-certificates"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Mozilla CA trust store and update-ca-certificates"
COPY --from=build /src/target/ /target/
