ARG VERSION=8.0.8

FROM oci.badsysadm.local:80/dep/security/suricata:${VERSION} AS build
ARG VERSION

WORKDIR /src/suricata
ENV CARGO_NET_OFFLINE=true
ENV CARGO_BUILD_OFFLINE=true
ENV RUSTFLAGS="-C debuginfo=0 -C link-arg=-static-libgcc"

RUN autoreconf -fvi

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-unittests \
    --disable-gccmarch-native \
    --disable-suricata-update \
    --disable-python \
    --enable-nfqueue \
    --enable-nflog \
    --enable-ebpf \
    --enable-ebpf-build \
    --disable-af-xdp \
    --disable-dpdk \
    --disable-pfring \
    --enable-libmagic \
    --enable-geoip \
    CFLAGS="-O2 -fPIC" \
    LDFLAGS="-L/usr/local/lib64 -L/usr/local/lib -static-libgcc -Wl,-z,relro,-z,now" \
    LIBS="-Wl,-Bstatic -Wl,--start-group \
    -lpcap -lyaml -ljansson -lpcre2-8 \
    -lbpf -lelf -lzstd -lz \
    -lcap-ng -lnet -lnetfilter_log -lnetfilter_queue -lnfnetlink \
    -llz4 -lmagic -lmaxminddb \
    -lcrypto -lxxhash \
    -Wl,--end-group -Wl,-Bdynamic -lm -ldl -lpthread"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN make install-conf DESTDIR=/src/target

RUN install -d /src/target/usr/libexec/suricata/ebpf && \
    install -m 0644 ebpf/*.bpf /src/target/usr/libexec/suricata/ebpf/
RUN install -D -m 0644 /usr/share/file/magic.mgc /src/target/usr/share/file/magic.mgc && \
    install -d /src/target/usr/share/misc && \
    ln -s ../file/magic.mgc /src/target/usr/share/misc/magic.mgc

# Only runtime artifacts and real configuration files belong in the bundle.
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/locale \
    /src/target/usr/lib/*.la \
    /src/target/usr/lib64/*.la


FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="suricata"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Suricata network intrusion detection and prevention engine"
COPY --from=build /src/target/ /target/
