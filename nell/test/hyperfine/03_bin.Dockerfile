ARG VERSION=2.0.0

FROM oci.badsysadm.local:80/dep/test/hyperfine:${VERSION} AS build
ARG VERSION

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}
ENV CARGO_NET_OFFLINE=true

WORKDIR /src/hyperfine

# build.rs generates shell completion scripts used by the installed tool.
RUN mkdir -p /src/target/usr/share/hyperfine/completions && \
    SHELL_COMPLETIONS_DIR=/src/target/usr/share/hyperfine/completions \
    RUSTFLAGS="-C link-arg=-static-libgcc" \
    cargo build --offline --locked --release --bin hyperfine && \
    install -D -m 0755 target/release/hyperfine /src/target/usr/bin/hyperfine

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="hyperfine"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Command-line benchmarking tool"
COPY --from=build /src/target/ /target/
