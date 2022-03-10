from flask import Blueprint
from flask_restx import Api

from .superheroes import api as superheroes_api


blueprint = Blueprint("apiV1", __name__)
api = Api(
    blueprint,
    title="My Title",
    version="1.0",
    description="A description",
    # All API metadatas
)

api.add_namespace(superheroes_api)
