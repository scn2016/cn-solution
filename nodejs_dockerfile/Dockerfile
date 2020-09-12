FROM node:8-alpine
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . .
RUN npm install express -y
EXPOSE 5000
CMD [ "node", "server.js" ]
