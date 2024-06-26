FROM postgres:15.4-bookworm
RUN apt-get update && apt-get install -y postgresql-15-partman && apt-get clean -y autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

