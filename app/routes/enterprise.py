from typing import List, Type

from fastapi import APIRouter, Depends
from pydantic import BaseModel, validator
from pydantic.errors import PydanticValueError
from starlette.status import HTTP_201_CREATED

from .. import models, validators
from .auth import CurrentUser, current_user_responses

# class CurrentUserEnterpriseRoles():
#     def __init__(roles : List[ models.UserEnterpriseRoles], request: Request):


def get_enterprise_router():
    enterprise_router = APIRouter(tags=["Enterprise"])

    class EnterpriseResponse(BaseModel):
        enterprise_id: int
        name: str
        role: models.UserEnterpriseRoles
        nip_number: validators.NipNumber
        address: str

    @enterprise_router.get(
        "/enterprise",
        response_model=List[EnterpriseResponse],
        responses={**current_user_responses()},
    )
    async def get_user_enterprises(
        page: int, user: models.User = Depends(CurrentUser())
    ):
        enterprises = (
            await models.UserEnterprise.objects.filter(user_id=user.id)
            .select_related("enterprise_id")
            .all()
        )
        enterprises_formatted = [
            EnterpriseResponse(
                enterprise_id=enterprise.enterprise_id.id,
                name=enterprise.enterprise_id.name,
                role=enterprise.role,
                nip_number=enterprise.enterprise_id.nip_number,
                address=enterprise.enterprise_id.address,
            )
            for enterprise in enterprises
        ]

        return enterprises_formatted

    class EnterpriseCreateInput(BaseModel):
        nip_number: validators.NipNumber
        name: str
        address: str

    class EnterpriseCreateResponse(BaseModel):

        id: int
        nip_number: validators.NipNumber
        name: str
        address: str

    @enterprise_router.post(
        "/enterprise",
        response_model=EnterpriseCreateResponse,
        status_code=HTTP_201_CREATED,
        responses={**current_user_responses()},
    )
    async def create_enterprise(
        enterprise: EnterpriseCreateInput,
        user: models.User = Depends(CurrentUser()),
    ):
        new_enterprise = await models.Enterprise(**enterprise.dict()).save()
        user_enterprise_connection = await models.UserEnterprise(
            user_id=user.id,
            enterprise_id=new_enterprise.id,
            role=models.UserEnterpriseRoles.admin.value,
        ).save()
        return new_enterprise.dict()

    return enterprise_router
