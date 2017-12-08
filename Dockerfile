FROM postgres:9.6

MAINTAINER Sébastien HELBERT sebastien.helbert@netapsys.fr

COPY backup.sh /backup.sh

RUN chmod +x /backup.sh

CMD ["/backup.sh"]