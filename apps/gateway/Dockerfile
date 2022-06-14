FROM node:17-slim AS base
WORKDIR /usr/app


FROM base AS dependencies
COPY package.json package-lock.json ./
RUN npm install --production


FROM base AS release
COPY --from=dependencies /usr/app/node_modules ./node_modules
COPY . .

ARG REPOSITORY_URL
ARG COMMIT_SHA
ARG RELEASE_TAG

ENV NEW_RELIC_METADATA_REPOSITORY_URL=$REPOSITORY_URL
ENV NEW_RELIC_METADATA_COMMIT=$COMMIT_SHA
#ENV NEW_RELIC_METADATA_RELEASE_TAG=$RELEASE_TAG

ENV HTTP_PORT 3000
EXPOSE ${HTTP_PORT}
CMD node server.js