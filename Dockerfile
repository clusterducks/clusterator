FROM ubuntu

ADD clusterator_*_all.tar.gz .

ENTRYPOINT ["/usr/local/bin/clusterator"]
