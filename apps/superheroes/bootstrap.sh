#!/bin/sh
export FLASK_APP=./app.py
export FLASK_DEBUG=1
NEW_RELIC_CONFIG_FILE=newrelic.ini newrelic-admin run-program flask run -h 0.0.0.0 -p $HTTP_PORT