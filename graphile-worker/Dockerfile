FROM node:12-alpine

RUN npm install -g graphile-worker@v0.1.0-alpha.0
RUN npm install -g axios@0.19.0

ENV NODE_PATH=/usr/local/lib/node_modules

CMD /usr/local/bin/graphile-worker