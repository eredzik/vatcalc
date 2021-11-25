from typing import List, Optional, Type

from app.routes.utils import Message
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, validator
from pydantic.errors import PydanticValueError
from starlette.responses import JSONResponse
from starlette.status import HTTP_201_CREATED, HTTP_409_CONFLICT, HTTP_204_NO_CONTENT

from .. import models, validators
from .auth import CurrentUser, current_user_responses
from .utils import (
    Message,
    get_verify_enterprise_permissions_responses,
    verify_enterprise_permissions,
    verify_granting_permissions
)

def get_enterprise_router():
    enterprise_router = APIRouter(tags=["Enterprise"])

    class EnterpriseResponse(BaseModel):
        enterprise_id: int
        name: str
        role: models.UserEnterpriseRoles
        nip_number: validators.NipNumber
        address: str

    class EnterpriseCreateInput(BaseModel):
        nip_number: validators.NipNumber
        name: str
        address: str

    class EnterpriseCreateResponse(BaseModel):
        id: int
        nip_number: validators.NipNumber
        name: str
        address: str

    class EnterpriseUpdateResponse(BaseModel):
        name: Optional[str]
        address: Optional[str]
        nip_number: Optional[validators.NipNumber]

    class UserEnterpriseResponse(BaseModel):
        enterprise_id: int
        user_id: int
        role: models.UserEnterpriseRoles

    class UserEnterpriseGrantAccess(BaseModel):
        user_id: int
        role_to_grant: str

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

    @enterprise_router.post(
        "/enterprise",
        response_model=EnterpriseCreateResponse,
        status_code=HTTP_201_CREATED,
        responses={**current_user_responses(), HTTP_409_CONFLICT: {"model": Message}},
    )
    async def create_enterprise(
        enterprise: EnterpriseCreateInput,
        user: models.User = Depends(CurrentUser()),
    ):
        existing_enterprise = await models.UserEnterprise.objects.select_related(
            [models.UserEnterprise.enterprise_id]
        ).all(user_id=user.id, enterprise_id__nip_number=enterprise.nip_number)
        if existing_enterprise == []:
            new_enterprise = await models.Enterprise(**enterprise.dict()).save()
            user_enterprise_connection = await models.UserEnterprise(
                user_id=user.id,
                enterprise_id=new_enterprise.id,
                role=models.UserEnterpriseRoles.admin.value,
            ).save()
            return new_enterprise.dict()
        else:
            return JSONResponse(
                Message(detail="Enterprise exists").json(),
                status_code=HTTP_409_CONFLICT,
            )

    @enterprise_router.patch(
        "/enterprise/{enterprise_id}",
        status_code=200,
        response_model=EnterpriseUpdateResponse,
        responses={**get_verify_enterprise_permissions_responses()},
    )
    async def update_enterprise(
        enterprise_id: int,
        item: EnterpriseUpdateResponse,
        user: models.User = Depends(CurrentUser()),
    ):
        enterprise = await models.Enterprise.objects.get_or_none(id=enterprise_id)
        if not enterprise:
            raise HTTPException(
                status_code=404, detail=f"Invoice {enterprise_id} not found"
            )

        permissions = await verify_enterprise_permissions(
            user,
            enterprise_id,
            required_permissions=[
                models.UserEnterpriseRoles.admin,
            ],
        )
        if permissions is True:
            update_data = item.dict(exclude_unset=True)
            await enterprise.update(**update_data)
            enterprise_output = EnterpriseResponse(
                enterprise_id=enterprise.id,
                name=enterprise.name,
                role="ADMIN",
                nip_number=enterprise.nip_number,
                address=enterprise.address,
            )
            return enterprise_output
        return permissions

    @enterprise_router.delete(
        "/enterprise/{enterprise_id}",
        status_code=200,
        responses={**get_verify_enterprise_permissions_responses()},
    )
    async def delete_enterprise(
        enterprise_id: int, user: models.User = Depends(CurrentUser())
    ):

        enterprise = await models.Enterprise.objects.get_or_none(id=enterprise_id)
        if not enterprise:
            raise HTTPException(
                status_code=404, detail=f"Enterprise {enterprise_id} not found"
            )

        permissions = await verify_enterprise_permissions(
            user,
            enterprise_id,
            required_permissions=[
                models.UserEnterpriseRoles.admin,
            ],
        )
        if permissions is True:
            await enterprise.delete()
            return JSONResponse({"message": f"Deleted enterprise {enterprise_id}"})

    @enterprise_router.post(
        "/enterprise/{enterprise_id}/access",
        response_model=UserEnterpriseGrantAccess,
        responses={**get_verify_enterprise_permissions_responses()}
    )
    async def grant_permissions(
        enterprise_id: int,
        item: UserEnterpriseGrantAccess,
        user: models.User = Depends(CurrentUser()),
    ):

        permissions = await verify_granting_permissions(
            user,
            enterprise_id,
            item.role_to_grant,
            required_permissions=[
                models.UserEnterpriseRoles.admin,
            ],
        )
        if permissions is True:
            existing_role = await models.UserEnterprise.objects.get_or_none(user_id=item.user_id, enterprise_id=enterprise_id, role=item.role_to_grant)
            if existing_role is not None:
                return HTTPException(status_code=HTTP_409_CONFLICT, detail=f"This user is already assigned to enterprise {enterprise_id} as {item.role_to_grant}.")
            else:
                new_role = await models.UserEnterprise(enterprise_id=enterprise_id, user_id=item.user_id, role=item.role_to_grant).save()
                return JSONResponse(status_code=HTTP_204_NO_CONTENT)


    return enterprise_router
