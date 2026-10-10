ARG VERSION=3.22.0

FROM oci.badsysadm.local:80/src/system/logrotate:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=oci.badsysadm.local:80/bin/security/acl:2.4.0 \
    /target/usr/include/ \
    /usr/include/

COPY --from=oci.badsysadm.local:80/bin/security/acl:2.4.0 \
    /target/usr/lib/x86_64-linux-gnu/libacl.a \
    /usr/lib/x86_64-linux-gnu/libacl.a

COPY --from=src_image /src/ /src/
