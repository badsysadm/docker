FROM gentoo/stage3:systemd-20240219 AS build
RUN emerge --sync
RUN emerge -v =net-mail/rss2email-3.14
COPY rss2email.service  /etc/systemd/system/
COPY rss2email.timer    /etc/systemd/system/
