from typing import List, Type

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

tradingpartner_router = APIRouter(tags=["Trading Partner"])

TradingPartnerInput: Type[models.TradingPartner] = models.TradingPartner.get_pydantic(
    exclude={"id"}
)  # type: ignore


@tradingpartner_router.post(
    "/trading_partner",
    status_code=HTTP_201_CREATED,
    response_model=models.TradingPartner,
    responses={
        HTTP_409_CONFLICT: {"model": Message},
        **get_verify_enterprise_permissions_responses(),
    },
)
async def add_trading_partner(
    trading_partner: TradingPartnerInput,
    user: User = Depends(fastapi_users.current_user()),
):
    validated_or_error = await verify_enterprise_permissions(
        user,
        trading_partner.enterprise.id,
        [models.UserEnterpriseRoles.editor, models.UserEnterpriseRoles.admin],
    )
    if validated_or_error is True:
        existing_trading_partner = await models.TradingPartner.objects.get_or_none(
            nip_number=trading_partner.nip_number
        )
        if existing_trading_partner is None:
            return await models.TradingPartner(**trading_partner.dict()).save()
        else:
            return JSONResponse(
                status_code=HTTP_409_CONFLICT, content={"message": "Entity exists"}
            )
    else:
        return validated_or_error


TradingPartnerResponse = models.TradingPartner.get_pydantic(
    include={"address", "id", "name", "nip_number"}
)


@tradingpartner_router.get(
    "/trading_partner",
    response_model=List[models.Invoice],
    status_code=200,
    responses={**get_verify_enterprise_permissions_responses()},
)
async def get_invoices(
    page: int,
    enterprise_id: int,
    user: User = Depends(fastapi_users.current_user()),
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
        partners = await models.TradingPartner.objects.paginate(page=page).all(
            enterprise__id=enterprise_id
        )
        return partners
    else:
        return permissions