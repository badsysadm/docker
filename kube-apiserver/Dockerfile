FROM alpine:latest AS build
WORKDIR /src
RUN apk update && apk add wget
RUN wget https://dl.k8s.io/release/v1.31.1/bin/linux/amd64/kube-apiserver 
RUN chmod +x ./kube-apiserver
COPY kube-apiserver.service ./kube-apiserver.service

FROM scratch
COPY --from=build --chmod=750 /src/kube-apiserver /usr/sbin/kube-apiserver
COPY --from=build --chmod=644 /src/kube-apiserver.service /etc/systemd/system/kube-apiserver.service
