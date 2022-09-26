import logging
import os

import newrelic.agent
from flask import Flask, request, url_for
from flask_cors import CORS
from newrelic.agent import NewRelicContextFormatter

from apis.v1 import blueprint as api_v1
from apis.v2 import blueprint as api_v2


logging.basicConfig(level=logging.INFO)


# Instantiate a new log handler
handler = logging.StreamHandler()

# Instantiate the log formatter and add it to the log handler
formatter = NewRelicContextFormatter()
handler.setFormatter(formatter)

# Get the root logger and add the handler to it
root_logger = logging.getLogger()
root_logger.addHandler(handler)


app = Flask(__name__)
app.config["RESTX_ERROR_404_HELP"] = False


@api_v1.before_request
def v1version():
    newrelic.agent.add_custom_parameter("apiVersion", "v1")


@api_v2.before_request
def v2version():
    newrelic.agent.add_custom_parameter("apiVersion", "v2")


app.register_blueprint(api_v1, url_prefix="/v1")
app.register_blueprint(api_v2, url_prefix="/v2")

log_level = logging.INFO
app.logger.setLevel(log_level)
# enable CORS
CORS(app, resources={r"/*": {"origins": "*"}})

HTTP_PORT = os.environ.get("HTTP_PORT")


@app.route("/ping")
def ping():
    return "healthy"


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
