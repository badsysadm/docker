FROM oci.badsysadm.local:80/get/source:latest AS build

ARG VERSION=1.22.2

RUN mkdir -p /src/krb5 && \
    wget -qO- https://web.mit.edu/kerberos/dist/krb5/1.22/krb5-${VERSION}.tar.gz | \
        tar -xzf - -C /src/krb5 --strip-components=1

FROM scratch
COPY --from=build /src/krb5/ /src/
