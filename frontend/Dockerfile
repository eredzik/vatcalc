FROM node:16
WORKDIR /usr/src/frontend/

RUN apt-get update && \
    apt-get install -y default-jre

ENV WAIT_VERSION 2.7.2
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait

COPY ["package.json", "package-lock.json"]
CMD ["sh", "./scripts/start_docker.sh" ]