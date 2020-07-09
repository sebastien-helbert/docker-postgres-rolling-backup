FROM postgres:12

LABEL maintainer="Sébastien HELBERT <sebastien.helbert@gmail.com>"

COPY backup.sh /backup.sh

RUN chmod +x /backup.sh

CMD ["/backup.sh"]
