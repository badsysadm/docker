FROM 127.0.0.1:12670/distro/debian:trixie

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    devscripts equivs debhelper \
    > /dev/null
