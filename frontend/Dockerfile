FROM node:16
WORKDIR /app

RUN apt-get update && \
    apt-get install -y default-jre

ENV PATH /app/node_modules/.bin:$PATH

ENV WAIT_VERSION 2.7.2
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait
COPY "package.json" "package.json"
COPY "package-lock.json" "package-lock.json"
COPY . .
RUN npm install
CMD ["./generate_api.sh"]