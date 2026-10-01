FROM 127.0.0.1:12670/distro/debian:trixie

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    ca-certificates git wget quilt xz-utils
RUN mkdir -p /src/target
