FROM node:20-alpine

LABEL org.opencontainers.image.source=https://github.com/qa-tech-training/qadevoprac3-capstone-lab-starter

USER 1000

WORKDIR app

COPY package* .

RUN npm install

COPY server.js .

CMD ["node", "server.js"]