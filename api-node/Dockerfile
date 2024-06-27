FROM node:19.6-alpine

WORKDIR /usr/src/app

ENV NODE_ENV production

COPY package*.json ./

RUN --mount=type=cache, target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci --only=production 
#adding only production dependencies, adding caching memory for better development speed to acheive

USER node

COPY --chown=node:node ./src .

EXPOSE 3000 

CMD [ "node", "index.js" ]
