#!/bin/bash

set -e

REF=${SOURCE_REF:-"main"}
TARGET=${INPUT_BRANCHNAME:-"demo"}
git update-ref -d refs/heads/$TARGET

git fetch origin $REF

COMMIT_1_DATE=$(date --date="7 day ago" -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_1_NAME=${INPUT_USER1_NAME:-"User One"}
COMMIT_1_EMAIL=${INPUT_USER1_EMAIL:-"userone@example.com"}

COMMIT_2_DATE=$(date --date="3 day ago" -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_2_NAME=${INPUT_USER2_NAME:-"User Two"}
COMMIT_2_EMAIL=${INPUT_USER2_EMAIL:-"usertwo@example.com"}

export GIT_AUTHOR_NAME=$COMMIT_1_NAME
export GIT_AUTHOR_EMAIL=$COMMIT_1_EMAIL
export GIT_AUTHOR_DATE=$COMMIT_1_DATE
export GIT_COMMITTER_NAME=$COMMIT_1_NAME
export GIT_COMMITTER_EMAIL=$COMMIT_1_EMAIL
export GIT_COMMITTER_DATE=$COMMIT_1_DATE
git checkout -f --orphan $TARGET
git restore --staged --source=origin/$REF .github/workflows/build-push-image.yml
git restore --staged --source=origin/backstage apps
git commit -m "Working hard on v1 of our API!"


git restore --staged --source=origin/main apps

export GIT_AUTHOR_NAME=$COMMIT_2_NAME
export GIT_AUTHOR_EMAIL=$COMMIT_2_EMAIL
export GIT_AUTHOR_DATE=$COMMIT_2_DATE
export GIT_COMMITTER_NAME=$COMMIT_2_NAME
export GIT_COMMITTER_EMAIL=$COMMIT_2_EMAIL
export GIT_COMMITTER_DATE=$COMMIT_2_DATE
git commit -m "Updating API to version 2!"
