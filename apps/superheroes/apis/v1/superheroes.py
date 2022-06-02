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
            ), skip_none=True
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
            ), skip_none=True
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
            ), skip_none=True
        ),
        "work": fields.Nested(
            api.model("Work", {"occupation": fields.String, "base": fields.String}), skip_none=True
        ),
        "connections": fields.Nested(
            api.model(
                "Connections",
                {"groupAffiliation": fields.String, "relatives": fields.String},
            ), skip_none=True
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
class SuperheroBySlug(Resource):
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


comparison_model = api.model(
    "Comparison",
    {
        "comparator": fields.String,
        "difference": fields.Integer,
        "order": fields.List(fields.Nested(superhero_model, skip_none=True))
    }
)

comparison_parser = api.parser()
comparison_parser.add_argument('superhero1', required=True)
comparison_parser.add_argument('superhero2', required=True)
comparison_parser.add_argument('comparator', required=True, choices=(
    "intelligence", "strength", "speed", "durability", "power", "combat"))


@api.route("/compare")
@api.doc(params={"superhero1": "Superhero ID", "superhero2": "Superhero ID"})
@api.response(404, "One or more of the superheroes was not found")
class CompareSuperheroes(Resource):
    @api.expect(comparison_parser)
    @api.marshal_with(comparison_model, skip_none=True)
    def get(self):
        """Compare two superheroes by one of their powerstats fields"""
        args = comparison_parser.parse_args()
        sh1 = db.get(Superheroes.slug == args["superhero1"])
        sh2 = db.get(Superheroes.slug == args["superhero2"])
        first = None
        second = None
        if (sh1["powerstats"][args["comparator"]] >= sh2["powerstats"][args["comparator"]]):
            first = sh1
            second = sh2
        else:
            first = sh2
            second = sh1
        result = {
            "comparator": args["comparator"],
            "difference": first["powerstats"][args["comparator"]] - second["powerstats"][args["comparator"]],
            "order": [
                {
                    "id": first["id"],
                    "name": first["name"],
                    "slug": first["slug"],
                    "powerstats": {
                        args["comparator"]: first["powerstats"][args["comparator"]]
                    }
                },
                {
                    "id": second["id"],
                    "name": second["name"],
                    "slug": second["slug"],
                    "powerstats": {
                        args["comparator"]: second["powerstats"][args["comparator"]]
                    }
                },
            ]
        }

        return result
