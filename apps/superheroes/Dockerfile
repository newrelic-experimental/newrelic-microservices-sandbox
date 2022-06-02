# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Use an official Python runtime as an image
FROM python:3.9-slim

RUN apt-get update \
    && apt-get install curl -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /superheroes
WORKDIR /superheroes

# We copy just the requirements.txt first to leverage Docker cache
COPY requirements.txt /superheroes
RUN pip install -r requirements.txt

COPY . /superheroes

ARG REPOSITORY_URL
ARG COMMIT_SHA
ARG RELEASE_TAG

ENV NEW_RELIC_METADATA_REPOSITORY_URL=$REPOSITORY_URL
ENV NEW_RELIC_METADATA_COMMIT=$COMMIT_SHA
ENV NEW_RELIC_METADATA_RELEASE_TAG=$RELEASE_TAG

# ENV AGG_APP_URL='http://prodinfo.octank-mesh-ns.svc.cluster.local:3000/productAgreement'

#WORKDIR /docker_app
EXPOSE 8080
ENTRYPOINT ["/superheroes/bootstrap.sh"]