import dataclasses
from typing import List

from app.routes.auth import CurrentUser
from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from starlette.status import HTTP_201_CREATED, HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT

from .. import models, validators
from .utils import (
    Message,
    get_verify_enterprise_permissions_responses,
    verify_enterprise_permissions,
)

vatrate_router = APIRouter(tags=["Vat Rate"])


class VatrateInput(BaseModel):
    vat_rate: float
    comment: str
    enterprise_id: int


class VatRateResponse(BaseModel):
    id: int
    vat_rate: float
    comment: str
    enterprise_id: int


@vatrate_router.post(
    "/vatrate",
    status_code=HTTP_201_CREATED,
    response_model=VatRateResponse,
    responses={
        HTTP_409_CONFLICT: {"model": Message},
        **get_verify_enterprise_permissions_responses(),
    },
)
async def add_vatrate(
    vatrate: VatrateInput,
    user: models.User = Depends(CurrentUser()),
):
    validated_or_error = await verify_enterprise_permissions(
        user,
        vatrate.enterprise_id,
        [models.UserEnterpriseRoles.editor, models.UserEnterpriseRoles.admin],
    )
    if validated_or_error is True:
        existing_vatrate = await models.VatRate.objects.get_or_none(
            vat_rate=vatrate.vat_rate
        )
        if existing_vatrate is None:
            created_vatrate = await models.VatRate(**vatrate.dict()).save()

            response = VatRateResponse(
                id=created_vatrate.id,
                vat_rate=created_vatrate.vat_rate,
                comment=created_vatrate.comment,
                enterprise_id=created_vatrate.enterprise_id.id,
            )
            return response
        else:
            return JSONResponse(
                status_code=HTTP_409_CONFLICT, content={"message": "Entity exists"}
            )

    else:
        return validated_or_error


@vatrate_router.get(
    "/vatrate",
    response_model=List[VatRateResponse],
    status_code=200,
    responses={**get_verify_enterprise_permissions_responses()},
)
async def get_vat_rates(
    page: int,
    enterprise_id: int,
    user: models.User = Depends(CurrentUser()),
):
    permissions = await verify_enterprise_permissions(
        user,
        enterprise_id,
        required_permissions=[
            models.UserEnterpriseRoles.viewer,
            models.UserEnterpriseRoles.editor,
            models.UserEnterpriseRoles.admin,
        ],
    )
    if permissions is True:
        vatrates = await models.VatRate.objects.paginate(page=page).all(
            enterprise_id=enterprise_id
        )
        response = [
            VatRateResponse(
                id=vatrate.id,
                vat_rate=vatrate.vat_rate,
                comment=vatrate.comment,
                enterprise_id=vatrate.enterprise_id.id,
            )
            for vatrate in vatrates
        ]
        return response
    else:
        return permissions
