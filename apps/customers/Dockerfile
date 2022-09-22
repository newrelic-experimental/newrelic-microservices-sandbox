
   
ARG GO_VERSION=1.15

FROM golang:${GO_VERSION}-alpine AS builder

RUN apk update && apk add alpine-sdk git && rm -rf /var/cache/apk/*

RUN mkdir -p /var/src/app/
WORKDIR /var/src/app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o ./dist/service ./*.go
FROM alpine:latest


ENV GIN_MODE=release
ENV PORT=5010

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

RUN mkdir -p /var/run/customers
WORKDIR /var/run/customers
COPY --from=builder /var/src/app/docs ./docs
COPY --from=builder /var/src/app/dist/service .



ARG REPOSITORY_URL
ARG COMMIT_SHA
ARG RELEASE_TAG

ENV NEW_RELIC_METADATA_REPOSITORY_URL=$REPOSITORY_URL
ENV NEW_RELIC_METADATA_COMMIT=$COMMIT_SHA
ENV NEW_RELIC_METADATA_RELEASE_TAG=$RELEASE_TAG

EXPOSE $PORT

ENTRYPOINT ["./service"]