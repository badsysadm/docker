FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG XZ_VERSION=v5.6.2

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential cmake git ca-certificates

RUN git clone --single-branch --branch ${XZ_VERSION} --depth 1 https://github.com/tukaani-project/xz.git /src/xz
RUN mkdir -p /src/xz/.build /src/target

#WORKDIR /src/xz/.build
WORKDIR /src/xz
RUN cmake -B build \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_NLS=OFF \
    -DXZ_DOC=OFF \
    -DXZ_DOXYGEN=OFF

RUN cmake --build build -j$(nproc)
RUN DESTDIR=/src/target cmake --install build
#RUN make -j$(nproc)
#RUN make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="xz"
LABEL org.opencontainers.image.version="5.6.2"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="XZ Utils and liblzma"
COPY --from=build /src/target/ /
