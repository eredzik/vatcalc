from pydantic.main import BaseModel
from tortoise import fields
from tortoise.models import Model


class User(Model):
    id = fields.IntField(pk=True)
    username = fields.CharField(50)
    password_hash = fields.CharField(128)


class UserCreate(BaseModel):
    username: str
    password_hash: str


class UserToken(BaseModel):
    access_token: str
    token_type: str = "bearer"
