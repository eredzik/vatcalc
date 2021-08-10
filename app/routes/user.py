from app.routes.auth import CurrentUser
from app.routes.utils import Message
from fastapi import APIRouter
from fastapi.param_functions import Depends
from pydantic.main import BaseModel
from starlette import status
from typing import Optional
from .utlis import verify_enterprise_permissions
from starlette.responses import JSONResponse
from starlette.status import HTTP_201_CREATED, HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT

from .. import models


def get_user_router():
    user_router = APIRouter(tags=["User"])

    class CurrentUserResponse(BaseModel):
        email: str
        username: str
        fav_enterprise_id: Optional[int] = None

    @user_router.get(
        "/user/me",
        response_model=CurrentUserResponse,
        responses={status.HTTP_401_UNAUTHORIZED: {"model": Message}},
    )
    async def get_user_data(user: models.User = Depends(CurrentUser())):
        user_data = CurrentUserResponse(
            email=user.email,
            username=user.username,
            fav_enterprise=user.fav_enterprise_id,
        )
        return user_data

    class UserUpdateEnterprise(CurrentUserResponse):
        fav_enterprise_id: int

    @user_router.patch(
        "/user/me/preferred_enterprise/",
        response_model=UserUpdateEnterprise,
    )
    async def update_enterprise(
        fav_enterprise: int, user: models.User = Depends(CurrentUser())
    ):
        permissions = await verify_enterprise_permissions(
            user,
            fav_enterprise,
            required_permissions=[
                models.UserEnterpriseRoles.editor,
                models.UserEnterpriseRoles.admin,
                models.UserEnterpriseRoles.viewer
            ],
        )
        if permissions is True:
            await user.update(fav_enterprise_id=fav_enterprise)
        else:
            return JSONResponse(
                status_code=HTTP_409_CONFLICT,
                content={"message": "Permissions error"}
            )
        return user


    return user_router
