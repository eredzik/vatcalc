from typing import List

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from starlette.status import HTTP_201_CREATED

from .. import models
from ..core.security import User, fastapi_users

enterprise_router = APIRouter(tags=["Enterprise1"])

EnterpriseResponse = models.Enterprise.get_pydantic(
    exclude={"tradingpartners", "userenterprises", "vatrates", "invoices"}
)


@enterprise_router.get(
    "/enterprise1",
    response_model=List[EnterpriseResponse],
)
async def get_user_enterprises(user: User = Depends(fastapi_users.current_user())):
    enterprises = (
        await models.UserEnterprise.objects.filter(user_id=user.id)
        .fields(["id", "name"])
        .all()
    )
    return enterprises


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
