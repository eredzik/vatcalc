from app.routes.auth import CurrentUser
from app.routes.utils import Message
from fastapi import APIRouter
from fastapi.param_functions import Depends
from pydantic.main import BaseModel
from starlette import status
from starlette.responses import JSONResponse

from .. import models


def get_user_router():
    user_router = APIRouter(tags=["User"])

    class CurrentUserResponse(BaseModel):
        email: str
        username: str

    @user_router.get(
        "/user/me",
        response_model=CurrentUserResponse,
        responses={status.HTTP_401_UNAUTHORIZED: {"model": Message}},
    )
    async def get_user_data(user: models.User = Depends(CurrentUser())):
        user_data = CurrentUserResponse(email=user.email, username=user.username)
        return user_data

    return user_router
