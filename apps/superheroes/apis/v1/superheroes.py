import logging
import random

from flask_restx import Namespace, Resource, errors, fields, reqparse

from repository import Superheroes, db


api = Namespace("superheroes", description="Api for working with Superheroes")

superhero_model = api.model(
    "Superhero",
    {
        "id": fields.Integer(required=True, description="Id"),
        "name": fields.String(required=True, description="The Superhero's name"),
        "slug": fields.String(
            required=True, description="Short, url-friendly identifier"
        ),
        "powerstats": fields.Nested(
            api.model(
                "PowerStats",
                {
                    "intelligence": fields.Integer(attribute="intelligence"),
                    "strength": fields.Integer,
                    "speed": fields.Integer,
                    "durability": fields.Integer,
                    "power": fields.Integer,
                    "combat": fields.Integer,
                },
            )
        ),
        "appearance": fields.Nested(
            api.model(
                "Appearance",
                {
                    "height": fields.List(fields.String),
                    "weight": fields.List(fields.String),
                    "eyeColor": fields.String,
                    "hairColor": fields.String,
                },
            )
        ),
        "biography": fields.Nested(
            api.model(
                "Biography",
                {
                    "fullName": fields.String,
                    "alterEgos": fields.String,
                    "aliases": fields.List(fields.String),
                    "placeOfBirth": fields.String,
                    "firstAppearance": fields.String,
                    "publisher": fields.String,
                    "alignment": fields.String,
                },
            )
        ),
        "work": fields.Nested(
            api.model("Work", {"occupation": fields.String, "base": fields.String})
        ),
        "connections": fields.Nested(
            api.model(
                "Connections",
                {"groupAffiliation": fields.String, "relatives": fields.String},
            )
        ),
    },
)

# @api.route('/')
# class CatList(Resource):
#     @api.doc('list_cats')
#     @api.marshal_list_with(cat)
#     def get(self):
#         '''List all cats'''
#         return CATS

@api.route("/random")
class RandomSuperheroes(Resource):
    @api.doc("")
    @api.marshal_list_with(superhero_model)
    def get(self):
        """Fetch a random number of superheroes"""
        parser = reqparse.RequestParser()
        parser.add_argument('num', type=int, default=1, help='Invalid num')
        args = parser.parse_args()
        logging.info(f"fetching {args['num']} random superheroes")
        superheroes = random.sample(db.all(), args["num"])
        return superheroes

@api.route("/<id>")
@api.param("id", "The superhero's identifier")
@api.response(404, "Superhero not found")
class Superhero(Resource):
    @api.doc("get_superhero")
    @api.marshal_with(superhero_model)
    def get(self, id):
        """Fetch a superhero given its identifier"""
        logging.info(f"fetching superhero {id}")
        sh = db.get(Superheroes.id == int(id))
        if sh is None:
            errors.abort(404, message="superhero not found", id=id)
        else:
            return sh

@api.route("/slug/<slug>")
@api.param("slug", "The superhero's slug")
@api.response(404, "Superhero not found")
class SuperheroBySlig(Resource):
    @api.doc("get_superhero_by_slug")
    @api.marshal_with(superhero_model)
    def get(self, slug):
        """Fetch a superhero given its slug"""
        logging.info(f"fetching superhero with slug: {slug}")
        sh = db.get(Superheroes.slug == slug)
        if sh is None:
            errors.abort(404, message="superhero not found", slug=slug)
        else:
            return sh