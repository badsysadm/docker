ARG VERSION=10.5p1

FROM oci.badsysadm.local:80/dep/system/openssh:${VERSION} AS dep_image
FROM dep_image AS build
ARG VERSION

WORKDIR /src/openssh

RUN autoreconf -fi
RUN export CFLAGS="-I/usr/local/include" && \
    export LDFLAGS="-L/usr/local/lib64" && \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc/ssh \
        --datadir=/usr/share/openssh \
        --with-privsep-path=/var/lib/empty \
        --with-pid-dir=/run \
        --with-ssl-dir=/usr/local \
        --with-pam \
        --with-kerberos5 \
        --with-libs="-Wl,-Bstatic -lcrypto -lz -lzstd -ldl -lpthread -Wl,-Bdynamic"
RUN make
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man

FROM scratch AS bundle 
LABEL org.opencontainers.image.title="openssh" 
LABEL org.opencontainers.image.version=${VERSION} 
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>" 
LABEL org.opencontainers.image.description="openssh bundle" 

COPY --from=build /src/target/ /target/
