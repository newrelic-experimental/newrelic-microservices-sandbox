#!/bin/bash

set -e

COMMIT_1_DATE=$(date --date="7 day ago" -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_1_NAME=${INPUT_USER1_NAME:-"User One"}
COMMIT_1_EMAIL=${INPUT_USER1_EMAIL:-"userone@example.com"}

COMMIT_2_DATE=$(date --date="3 day ago" -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_2_NAME=${INPUT_USER2_NAME:-"User Two"}
COMMIT_2_EMAIL=${INPUT_USER2_EMAIL:-"usertwo@example.com"}

COMMIT_1_TREE=$(git ls-tree backstage apps | git mktree)

export GIT_AUTHOR_NAME=$COMMIT_1_NAME
export GIT_AUTHOR_EMAIL=$COMMIT_1_EMAIL
export GIT_AUTHOR_DATE=$COMMIT_1_DATE
export GIT_COMMITTER_NAME=$COMMIT_1_NAME
export GIT_COMMITTER_EMAIL=$COMMIT_1_EMAIL
export GIT_COMMITTER_DATE=$COMMIT_1_DATE
COMMIT_1_HASH=$(git commit-tree -m "Working hard on v1 of our API!" $COMMIT_1_TREE)
git checkout $COMMIT_1_HASH

git restore --staged --source=main apps

export GIT_AUTHOR_NAME=$COMMIT_2_NAME
export GIT_AUTHOR_EMAIL=$COMMIT_2_EMAIL
export GIT_AUTHOR_DATE=$COMMIT_2_DATE
export GIT_COMMITTER_NAME=$COMMIT_2_NAME
export GIT_COMMITTER_EMAIL=$COMMIT_2_EMAIL
export GIT_COMMITTER_DATE=$COMMIT_2_DATE
git commit -m "Updating API to version 2!"

git update-ref -m "moving branch to updated commit" refs/heads/${INPUT_BRANCHNAME:-"demo"} HEAD
