FROM alpine:latest AS build
ARG VERSION=1.7.22
WORKDIR /src
RUN apk update && apk add wget
RUN wget -qO- https://github.com/containerd/containerd/releases/download/v$VERSION/containerd-$VERSION-linux-amd64.tar.gz | tar xvz -C /src/
RUN chmod +x ./bin/containerd ./bin/containerd-shim ./bin/containerd-shim-runc-v1 ./bin/containerd-shim-runc-v2
RUN wget -q https://github.com/opencontainers/runc/releases/download/v1.1.14/runc.amd64 -O ./runc
RUN wget -qO- https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz | tar xvz -C /src/
#COPY kube-apiserver.service ./kube-apiserver.service

#FROM scratch
#COPY --from=build --chmod=750 /src/bin/containerd /src/bin/containerd-shim /src/bin/containerd-shim-runc-v1 /src/bin/containerd-shim-runc-v2 /usr/sbin/
#COPY --from=build --chmod=644 /src/containerd.service /etc/systemd/system/containerd.service
