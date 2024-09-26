FROM alpine:latest AS build
ARG VERSION=1.7.22
WORKDIR /src
RUN apk update && apk add wget
RUN wget -qO- https://github.com/containerd/containerd/releases/download/v$VERSION/containerd-$VERSION-linux-amd64.tar.gz | tar xvz -C /src/
#RUN chmod +x ./kube-apiserver
#COPY kube-apiserver.service ./kube-apiserver.service

#FROM scratch
#COPY --from=build --chmod=750 /src/kube-apiserver /usr/sbin/kube-apiserver
#COPY --from=build --chmod=644 /src/kube-apiserver.service /etc/systemd/system/kube-apiserver.service
