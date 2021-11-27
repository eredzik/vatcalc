from pydantic.main import BaseModel


class Message(BaseModel):
    detail: str
