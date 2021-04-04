from fastapi import Depends, FastAPI
from starlette.graphql import GraphQLApp
from fastapi_sqlalchemy import db

from . import graphql_crud, models
from .database import engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="API")


# app.add_route("/", GraphQLApp(schema=graphql_crud.schema))
# app.add_route("/partners", )