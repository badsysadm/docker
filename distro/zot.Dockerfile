FROM golang:tip-alpine3.24 AS base
RUN apk update && apk add git make bash nodejs npm curl
ENV OS=linux
ENV GOOS=linux ARCH=amd64 CGO_ENABLED=0 GOEXPERIMENT=jsonv2 EXTENSIONS=""
WORKDIR /src/zot
RUN git clone https://github.com/project-zot/zot.git --single-branch --depth 1 --branch v2.1.18 /src/zot
#RUN make binary-minimal

RUN RELEASE_TAG=$(git describe --tags --always) && \
    COMMIT=$(git rev-parse --short HEAD) && \
    GO_VERSION=$(go version | awk '{print $3}') && \
    LDFLAGS="-X zotregistry.dev/zot/v2/pkg/api/config.ReleaseTag=${RELEASE_TAG} \
             -X zotregistry.dev/zot/v2/pkg/api/config.Commit=${COMMIT} \
             -X zotregistry.dev/zot/v2/pkg/api/config.BinaryType=minimal \
             -X zotregistry.dev/zot/v2/pkg/api/config.GoVersion=${GO_VERSION} \
             -s -w -extldflags -static" && \
    go build -buildmode=exe \
      -o bin/zot-linux-amd64-minimal \
      -v -trimpath \
      -ldflags "${LDFLAGS}" \
      ./cmd/zot

RUN bash -c "mkdir -p /opt/chroot/{etc,proc,sys,dev,run,tmp,var/tmp}"
RUN install -D /src/zot/bin/zot-linux-amd64-minimal /opt/chroot/usr/bin/zot
RUN cp -aL /etc/os-release /opt/chroot/etc/os-release
COPY ./zot.service /opt/chroot/etc/systemd/system/zot.service
COPY ./zot.config /opt/chroot/etc/zot/config.json

FROM scratch
COPY --from=base /opt/chroot /
