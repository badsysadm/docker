FROM alpine:latest
ENV GITEA_WORK_DIR /var/lib/gitea/
ENV HOME /var/lib/gitea
RUN apk update && apk add git bash
RUN adduser \
   --system \
   --shell /bin/bash \
   --gecos 'Git Version Control' \
   --disabled-password \
   --home /var/lib/gitea \
   git
RUN mkdir -p /var/lib/gitea/custom /var/lib/gitea/data /var/lib/gitea/log /etc/systemd/system/
RUN chown -R git /var/lib/gitea/
RUN chmod -R 750 /var/lib/gitea/
RUN mkdir /etc/gitea
RUN chown git /etc/gitea
RUN chmod 770 /etc/gitea
RUN wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/1.21.11/gitea-1.21.2-linux-amd64
RUN chmod +x /usr/local/bin/gitea
COPY gitea.service /etc/systemd/system/gitea.service
CMD ["/usr/local/bin/gitea", "web", "-c", "/etc/gitea/app.ini", "--work-path", "/var/lib/gitea"]
