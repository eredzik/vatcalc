from typing import List

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from starlette.status import HTTP_201_CREATED

from .. import models
from ..core.security import User, fastapi_users

enterprise_router = APIRouter(tags=["Enterprise1"])


class EnterpriseResponse(BaseModel):
    enterprise_id: int
    name: str
    role: models.UserEnterpriseRoles


@enterprise_router.get(
    "/enterprise1",
    response_model=List[EnterpriseResponse],
)
async def get_user_enterprises(user: User = Depends(fastapi_users.current_user())):
    enterprises = (
        await models.UserEnterprise.objects.filter(user_id=user.id)
        .select_related("enterprise_id")
        .all()
    )
    enterprises_formatted = [
        {
            "enterprise_id": enterprise.enterprise_id.id,
            "name": enterprise.enterprise_id.name,
            "role": enterprise.role,
        }
        for enterprise in enterprises
    ]

    return enterprises_formatted


class EnterpriseCreate(BaseModel):
    name: str


@enterprise_router.post(
    "/enterprise1", response_model=models.Enterprise, status_code=HTTP_201_CREATED
)
async def create_enterprise(
    enterprise: EnterpriseCreate, user: User = Depends(fastapi_users.current_user())
):
    new_enterprise = await models.Enterprise(**enterprise.dict()).save()
    user_enterprise_connection = await models.UserEnterprise(
        user_id=user.id,
        enterprise_id=new_enterprise.id,
        role=models.UserEnterpriseRoles.admin.value,
    ).save()
    return new_enterprise
