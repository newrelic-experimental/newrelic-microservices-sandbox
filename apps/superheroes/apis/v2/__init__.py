from flask import Blueprint
from flask_restx import Api

from .superheroes import api as superheroes_api


blueprint = Blueprint("apiV2", __name__)
api = Api(
    blueprint,
    title="Superhero Api",
    version="2.0",
    description="v2 of the Superhero Api",
    # All API metadatas
)

api.add_namespace(superheroes_api)
