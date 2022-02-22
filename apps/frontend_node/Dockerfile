FROM node:14



# Create app directory
WORKDIR /usr/src/app

COPY package.json package-lock.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

ARG REPOSITORY_URL
ARG COMMIT_SHA
ARG RELEASE_TAG


ENV NEW_RELIC_METADATA_REPOSITORY_URL = $REPOSITORY_URL
ENV NEW_RELIC_METADATA_COMMIT = $COMMIT_SHA
ENV NEW_RELIC_METADATA_RELEASE_TAG = $RELEASE_TAG
CMD [ "node", "server.js" ]