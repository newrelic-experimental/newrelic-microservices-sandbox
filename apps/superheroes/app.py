from flask import Flask, request, url_for
from flask_cors import CORS
import requests
import os
import logging
logging.basicConfig(level=logging.INFO)


from apis.v1 import blueprint as api_v1


app = Flask(__name__)
app.config['RESTX_ERROR_404_HELP'] = False
app.register_blueprint(api_v1, url_prefix='/api/v1')

log_level = logging.INFO
app.logger.setLevel(log_level)
# enable CORS
CORS(app, resources={r'/*': {'origins': '*'}})

HTTP_PORT = os.environ.get("HTTP_PORT")

@app.route('/ping')
def ping():
    return "healthy"


if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)