#!/bin/bash
COMMIT_1_DATE=$(date -v -7d -Iseconds)
COMMIT_1_NAME=${INPUT_USER1_NAME:-"User One"}
COMMIT_1_EMAIL=${INPUT_USER1_EMAIL:-"userone@example.com"}

COMMIT_2_DATE=$(date -v -3d -Iseconds)
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

COMMIT_2_TREE=$(git ls-tree main apps | git mktree)

export GIT_AUTHOR_NAME=$COMMIT_2_NAME
export GIT_AUTHOR_EMAIL=$COMMIT_2_EMAIL
export GIT_AUTHOR_DATE=$COMMIT_2_DATE
export GIT_COMMITTER_NAME=$COMMIT_2_NAME
export GIT_COMMITTER_EMAIL=$COMMIT_2_EMAIL
export GIT_COMMITTER_DATE=$COMMIT_2_DATE
COMMIT_2_HASH=$(git commit-tree -p $COMMIT_1_HASH -m "Updating API to version 2!"  $COMMIT_2_TREE)

git update-ref -m "moving branch to updated commit" refs/heads/${INPUT_BRANCHNAME:-"demo"} $COMMIT_2_HASH