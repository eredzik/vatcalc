FROM node:16
WORKDIR /usr/src/frontend/
COPY ["package.json", "package-lock.json", "./"]
RUN npm install
CMD ["npm", "run", "server" ]