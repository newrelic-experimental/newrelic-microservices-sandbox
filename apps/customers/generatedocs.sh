#!/bin/bash

docker run -v $(pwd):/tmp/docgen golang:1.15 sh -c "cd /tmp/docgen;go get -u github.com/swaggo/swag/cmd/swag;swag init"