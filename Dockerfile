FROM postgres:10.1

MAINTAINER Sébastien HELBERT sebastien.helbert@netapsys.fr

COPY backup.sh /backup.sh

RUN chmod +x /backup.sh

CMD ["/backup.sh"]
