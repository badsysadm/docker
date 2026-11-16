ARG VERSION=0.80

FROM oci.badsysadm.local:80/dep/test/nnd:${VERSION} AS build
ARG VERSION

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}
ENV CARGO_NET_OFFLINE=true

WORKDIR /src/nnd

RUN RUSTFLAGS="-C link-arg=-static-libgcc" \
    cargo build --offline --locked --release --bin nnd

RUN install -D -m 0755 target/release/nnd /src/target/usr/bin/nnd

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="nnd"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Fast native TUI debugger for Linux"
COPY --from=build /src/target/ /target/
