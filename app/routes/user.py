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
        fav_enterprise_id: int

    @user_router.get(
        "/user/me",
        response_model=CurrentUserResponse,
        responses={status.HTTP_401_UNAUTHORIZED: {"model": Message}},
    )
    async def get_user_data(user: models.User = Depends(CurrentUser())):
        user_data = CurrentUserResponse(
            email=user.email,
            username=user.username,
            favourite_enterprise=user.fav_enterprise)
        return user_data

    class UserUpdateEnterprise(BaseModel):
        fav_enterprise_id: int

    @user_router.patch(
        "/user/me/preferredEnterprise/",
        response_model=UserUpdateEnterprise,
    )
    async def update_enterprise(fav_enterprise: UserUpdateEnterprise,
                                user: models.User = Depends(CurrentUser())):
        stored_user_data = get_user_data(user)
        stored_user_model = UserUpdateEnterprise
        update_data = fav_enterprise.dict(exclude_unset=True)
        updated_item = stored_user_model.copy(update=update_data)
        new_settings = await models.User(**fav_enterprise.dict()).save()
        return new_settings.dict()

    return user_router
