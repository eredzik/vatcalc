from typing import Optional

from app.routes.auth import CurrentUser
from app.routes.utils import Message
from fastapi import APIRouter, HTTPException
from fastapi.param_functions import Depends
from pydantic.main import BaseModel
from starlette import status
from starlette.status import HTTP_404_NOT_FOUND

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
            fav_enterprise_id=user.fav_enterprise_id.id
            if user.fav_enterprise_id
            else None,
        )
        return user_data

    class UserUpdateEnterpriseResponse(CurrentUserResponse):
        email: Optional[str] = None
        username: Optional[str] = None
        fav_enterprise_id: int

    @user_router.patch(
        "/user/me/preferred_enterprise",
        response_model=UserUpdateEnterpriseResponse,
        responses={status.HTTP_401_UNAUTHORIZED: {"model": Message}},
    )
    async def update_enterprise(
        enterprise_id: int,
        user: models.User = Depends(
            CurrentUser(
                required_permissions=[
                    models.UserEnterpriseRoles.editor,
                    models.UserEnterpriseRoles.admin,
                    models.UserEnterpriseRoles.viewer,
                ],
            )
        ),
    ):
        await user.update(fav_enterprise_id=enterprise_id)
        return UserUpdateEnterpriseResponse(
            email=user.email,
            username=user.username,
            fav_enterprise_id=user.fav_enterprise_id.id,
        )

    class FavEnterpriseResponse(BaseModel):
        fav_enterprise: int

    @user_router.get(
        "/user/me/preferred_enterprise",
        response_model=FavEnterpriseResponse,
        responses={
            status.HTTP_409_CONFLICT: {"model": Message},
            HTTP_404_NOT_FOUND: {"model": Message},
        },
    )
    async def get_fav_enterprise(user: models.User = Depends(CurrentUser())):
        if user.fav_enterprise_id is not None:
            fav_enterprise = FavEnterpriseResponse(
                fav_enterprise=user.fav_enterprise_id.id
            )
            return fav_enterprise
        else:
            raise HTTPException(
                HTTP_404_NOT_FOUND, "Not found favorite enterprise."
            )

    return user_router
