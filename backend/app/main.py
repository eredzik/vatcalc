from fastapi import Depends, FastAPI
from starlette.graphql import GraphQLApp

from . import graphql_crud, models
from .database import engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()


app.add_route("/", GraphQLApp(schema=graphql_crud.schema))
