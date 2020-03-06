FROM docker.elastic.co/elasticsearch/elasticsearch:7.6.1
# https://hub.docker.com/_/elasticsearch
RUN mkdir /fargate
ADD ./singlemaster.config /fargate/singlemaster.config
ADD ./singlemasterinit.sh /fargate/singlemasterinit.sh
RUN chmod 755 /fargate/singlemaster.config
RUN chmod 755 /fargate/singlemasterinit.sh
RUN ls -al /fargate/
ENTRYPOINT ["sh", "-c","/fargate/singlemasterinit.sh"]
