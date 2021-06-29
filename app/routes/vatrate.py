from typing import Type

from fastapi import APIRouter, Depends, Response
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from starlette.status import HTTP_201_CREATED, HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT

from .. import models, validators
from ..core.security import User, fastapi_users
from .utils import (
    Message,
    get_verify_enterprise_permissions_responses,
    verify_enterprise_permissions,
)

vatrate_router = APIRouter(tags=["Vat Rate"])


VatrateInput: Type[models.VatRate] = models.VatRate.get_pydantic(exclude={"id"})  # type: ignore


@vatrate_router.post(
    "/vatrate",
    status_code=HTTP_201_CREATED,
    response_model=models.VatRate,
    responses={
        HTTP_409_CONFLICT: {"model": Message},
        **get_verify_enterprise_permissions_responses(),
    },
)
async def add_vatrate(
    vatrate: VatrateInput,
    user: User = Depends(fastapi_users.current_user()),
):
    validated_or_error = await verify_enterprise_permissions(
        user,
        vatrate.enterprise.id,
        [models.UserEnterpriseRoles.editor, models.UserEnterpriseRoles.admin],
    )
    if validated_or_error is True:
        existing_vatrate = await models.VatRate.objects.get_or_none(
            vat_rate=vatrate.vat_rate
        )
        if existing_vatrate is None:
            return await models.VatRate(**vatrate.dict()).save()
        else:
            return JSONResponse(
                status_code=HTTP_409_CONFLICT, content={"message": "Entity exists"}
            )

    else:
        return validated_or_error
