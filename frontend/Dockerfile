FROM node:16
WORKDIR /usr/src/

RUN apt-get update && \
    apt-get install -y default-jre

ENV WAIT_VERSION 2.7.2
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait
COPY "package.json" "package.json"
COPY "package-lock.json" "package-lock.json"
RUN npm install
USER node
WORKDIR /usr/src/frontend/
CMD ["sh", "./scripts/start_docker.sh" ]