ARG VERSION=1.3.1

FROM oci.badsysadm.local:80/dep/test/binary-security-check:${VERSION} AS build
ARG VERSION

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}
ENV CARGO_NET_OFFLINE=true

WORKDIR /src/binary-security-check

RUN RUSTFLAGS="-C link-arg=-static-libgcc" \
    cargo build --offline --locked --release --bin binary-security-check

RUN install -D -m 0755 target/release/binary-security-check \
    /src/target/usr/bin/binary-security-check

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="binary-security-check"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Binary security feature analyzer"
COPY --from=build /src/target/ /target/
