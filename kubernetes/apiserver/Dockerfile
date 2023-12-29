FROM alpine:latest
WORKDIR /src
RUN apt update && apk add wget
RUN wget https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kube-apiserver 
