FROM alpine:latest
WORKDIR /src
RUN apk update && apk add wget
RUN wget https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kube-apiserver 
RUN chmod +x ./kube-apiserver
COPY kube-apiserver.service /etc/systemd/system/kube-apiserver.service
