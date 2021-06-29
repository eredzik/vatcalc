from typing import List, Type

from fastapi import APIRouter, Depends
from pydantic import BaseModel, validator
from starlette.status import HTTP_201_CREATED

from .. import models, validators
from ..core.security import User, fastapi_users

enterprise_router = APIRouter(tags=["Enterprise"])


class EnterpriseResponse(BaseModel):
    enterprise_id: int
    name: str
    role: models.UserEnterpriseRoles


@enterprise_router.get(
    "/enterprise",
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


EnterpriseCreateInput: Type[models.Enterprise] = models.Enterprise.get_pydantic(exclude={"id"})  # type: ignore


class EnterpriseCreateResponse(BaseModel):
    id: int
    nip_number: str
    name: str
    address: str

    @validator("nip_number")
    def nip_validator(cls, nip):
        return validators.validate_nip(nip)


@enterprise_router.post(
    "/enterprise",
    response_model=EnterpriseCreateResponse,
    status_code=HTTP_201_CREATED,
)
async def create_enterprise(
    enterprise: EnterpriseCreateInput,
    user: User = Depends(fastapi_users.current_user()),
):
    new_enterprise = await models.Enterprise(**enterprise.dict()).save()
    user_enterprise_connection = await models.UserEnterprise(
        user_id=user.id,
        enterprise_id=new_enterprise.id,
        role=models.UserEnterpriseRoles.admin.value,
    ).save()
    return new_enterprise
