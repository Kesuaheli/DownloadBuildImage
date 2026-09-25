FROM ubuntu

RUN apt-get update && apt-get install -y \
    git \
	make

RUN mkdir -p /root/.ssh
RUN touch /root/.ssh/known_hosts
RUN touch /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa

COPY run.sh run.sh
RUN chmod 775 run.sh

CMD [ "./run.sh" ]
