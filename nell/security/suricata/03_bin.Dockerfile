ARG VERSION=8.0.8

FROM oci.badsysadm.local:80/dep/security/suricata:${VERSION} AS build
ARG VERSION

WORKDIR /src/suricata
ENV CARGO_NET_OFFLINE=true
ENV CARGO_BUILD_OFFLINE=true
ENV RUSTFLAGS="-C debuginfo=0"

# Link all non-libc libraries statically. Inspect the ELF after installation.
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-unittests \
    --disable-gccmarch-native \
    --disable-suricata-update \
    --disable-python \
    --disable-nfqueue \
    --disable-nflog \
    --disable-ebpf \
    --disable-ebpf-build \
    --disable-af-xdp \
    --disable-dpdk \
    --disable-pfring \
    --disable-libmagic \
    --disable-geoip \
    PKG_CONFIG="pkg-config --static" \
    CFLAGS="-O2 -fPIC" \
    LDFLAGS="-static-libgcc -Wl,-z,relro,-z,now"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN make install-conf DESTDIR=/src/target

# Only runtime artifacts and real configuration files belong in the bundle.
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/locale \
    /src/target/usr/include \
    /src/target/usr/lib/pkgconfig \
    /src/target/usr/lib64/pkgconfig \
    /src/target/usr/lib/*.la \
    /src/target/usr/lib64/*.la

RUN set -eu; \
    for executable in /src/target/usr/bin/suricata /src/target/usr/bin/suricatasc /src/target/usr/bin/suricatactl; do \
      if test -f "$executable"; then \
        needed="$(readelf -d "$executable" | grep NEEDED || true)"; \
        forbidden="$(printf "%s\\n" "$needed" | grep -v 'libc.so.6' || true)"; \
        if test -n "$forbidden"; then \
          echo "Unexpected shared dependencies in $executable: $forbidden" >&2; \
          exit 1; \
        fi; \
      fi; \
    done

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="suricata"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Suricata network intrusion detection and prevention engine"
COPY --from=build /src/target/ /target/
