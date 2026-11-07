ARG VERSION=0.6.3

FROM oci.badsysadm.local:80/dep/security/lldap:${VERSION} AS build
ARG VERSION

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}
ENV CARGO_NET_OFFLINE=true

WORKDIR /src/lldap
RUN cargo build --offline --locked --release \
    -p lldap -p lldap_migration_tool -p lldap_set_password

WORKDIR /src/lldap/app
RUN wasm-pack build --mode no-install --target web --release \
    && gzip -9 -n -k -f pkg/lldap_app_bg.wasm

WORKDIR /src/lldap
RUN install -D -m 0755 target/release/lldap /src/target/usr/sbin/lldap \
    && install -D -m 0755 target/release/lldap_migration_tool /src/target/usr/bin/lldap_migration_tool \
    && install -D -m 0755 target/release/lldap_set_password /src/target/usr/bin/lldap_set_password \
    && install -D -m 0644 app/index_local.html /src/target/usr/share/lldap/app/index.html \
    && cp -a app/static app/pkg /src/target/usr/share/lldap/app/

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="lldap"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Light LDAP directory server and Web UI"
COPY --from=build /src/target/ /target/
