from flask import Blueprint
from flask_restx import Api

from .superheroes import api as superheroes_api


blueprint = Blueprint("apiV1", __name__)
api = Api(
    blueprint,
    title="Superhero Api",
    version="1.0",
    description="v1 of the Superhero Api",
    # All API metadatas
)

api.add_namespace(superheroes_api)
