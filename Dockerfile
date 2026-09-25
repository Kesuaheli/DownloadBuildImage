FROM ubuntu

RUN apt-get update && apt-get install -y \
    curl \
    git \
	make
RUN curl -fsSL https://get.docker.com | sh

RUN mkdir -p /root/.ssh
RUN touch /root/.ssh/known_hosts

COPY run.sh run.sh
RUN chmod 775 run.sh

CMD [ "./run.sh" ]
