ARG VERSION=2.56.0

FROM oci.badsysadm.local:80/dep/dev/git:${VERSION} AS build
ARG VERSION

WORKDIR /src/git

RUN make -j$(nproc) \
    prefix=/usr \
    INSTALL_SYMLINKS=YesPlease \
    NO_INSTALL_HARDLINKS=YesPlease \
    CURL_CONFIG=/usr/local/bin/curl-config \
    CURL_CFLAGS=-I/usr/local/include \
    CURL_LDFLAGS="-Wl,-Bstatic -Wl,--start-group \
        /usr/local/lib/libcurl.a \
        /usr/local/lib/libssh2.a \
        /usr/local/lib/libnghttp2.a \
        /usr/local/lib64/libssl.a \
        /usr/local/lib64/libcrypto.a \
        /usr/local/lib/libzstd.a \
        /usr/local/lib/libz.a \
        -Wl,--end-group -Wl,-Bdynamic -ldl -pthread" \
    OPENSSLDIR=/usr/local \
    ZLIB_PATH=/usr/local \
    CFLAGS="-O2 -I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib64 -L/usr/local/lib -static-libgcc" \
    LIBS='$(filter-out %.o,$(GITLIBS)) -Wl,-Bstatic $(EXTLIBS) -lzstd -Wl,-Bdynamic'

RUN make install \
    prefix=/usr \
    DESTDIR=/src/target \
    INSTALL_SYMLINKS=YesPlease \
    NO_INSTALL_HARDLINKS=YesPlease \
    CURL_CONFIG=/usr/local/bin/curl-config \
    CURL_CFLAGS=-I/usr/local/include \
    CURL_LDFLAGS="-Wl,-Bstatic -Wl,--start-group \
        /usr/local/lib/libcurl.a \
        /usr/local/lib/libssh2.a \
        /usr/local/lib/libnghttp2.a \
        /usr/local/lib64/libssl.a \
        /usr/local/lib64/libcrypto.a \
        /usr/local/lib/libzstd.a \
        /usr/local/lib/libz.a \
        -Wl,--end-group -Wl,-Bdynamic -ldl -pthread" \
    OPENSSLDIR=/usr/local \
    ZLIB_PATH=/usr/local \
    CFLAGS="-O2 -I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib64 -L/usr/local/lib -static-libgcc" \
    LIBS='$(filter-out %.o,$(GITLIBS)) -Wl,-Bstatic $(EXTLIBS) -lzstd -Wl,-Bdynamic'

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="git"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Git distributed version control system"
COPY --from=build /src/target/ /target/
