FROM debian:trixie-20240211-slim AS build
WORKDIR /src
RUN apt-get update -y && apt-get install -y git golang-go make
RUN git clone --depth=1 --branch v0.3.8    https://github.com/grepplabs/kafka-proxy.git    kafka-proxy
WORKDIR /src/kafka-proxy
RUN make clean build

FROM scratch
COPY --from=build /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib/
COPY --from=build /src/kafka-proxy/build/kafka-proxy /usr/bin/
