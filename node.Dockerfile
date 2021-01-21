FROM node:15.6.0-alpine3.12

RUN mkdir /app
WORKDIR /app
COPY index.js /app
RUN chown -R node:node /app

USER node
CMD ["node", "index.js"]