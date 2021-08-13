from typing import List, Type

from app.routes.auth import CurrentUser
from fastapi import APIRouter, Depends, Response
from fastapi.exceptions import HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from requests.models import HTTPError
from starlette.status import HTTP_201_CREATED, HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT

from .. import models, validators
from .utils import (
    Message,
    get_verify_enterprise_permissions_responses,
    verify_enterprise_permissions,
)

tradingpartner_router = APIRouter(tags=["Trading Partner"])


class TradingPartnerInput(BaseModel):
    nip_number: validators.NipNumber
    name: str
    address: str
    enterprise_id: int


class TradingPartnerResponse(BaseModel):
    id: int
    nip_number: str
    name: str
    address: str
    enterprise_id: int


@tradingpartner_router.post(
    "/trading_partner",
    status_code=HTTP_201_CREATED,
    response_model=TradingPartnerResponse,
    responses={
        HTTP_409_CONFLICT: {"model": Message},
        **get_verify_enterprise_permissions_responses(),
    },
)
async def add_trading_partner(
    trading_partner: TradingPartnerInput,
    user: models.User = Depends(CurrentUser()),
):
    validated_or_error = await verify_enterprise_permissions(
        user,
        trading_partner.enterprise_id,
        [models.UserEnterpriseRoles.editor, models.UserEnterpriseRoles.admin],
    )
    if validated_or_error is True:
        existing_trading_partner = await models.TradingPartner.objects.get_or_none(
            nip_number=trading_partner.nip_number,
            enterprise_id=trading_partner.enterprise_id,
        )
        if existing_trading_partner is None:
            new_trading_partner = await models.TradingPartner(
                **trading_partner.dict()
            ).save()
            return TradingPartnerResponse(
                id=new_trading_partner.id,
                nip_number=new_trading_partner.nip_number,
                name=new_trading_partner.name,
                address=new_trading_partner.address,
                enterprise_id=new_trading_partner.enterprise_id.id,
            )
        else:
            raise HTTPException(HTTP_409_CONFLICT, "Entity exists")
    else:
        return validated_or_error


@tradingpartner_router.get(
    "/trading_partner",
    response_model=List[TradingPartnerResponse],
    status_code=200,
    responses={**get_verify_enterprise_permissions_responses()},
)
async def get_trading_partners(
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
        partners = await models.TradingPartner.objects.paginate(page=page).all(
            enterprise_id=enterprise_id
        )
        response = [
            TradingPartnerResponse(
                id=trading_partner.id,
                nip_number=trading_partner.nip_number,
                name=trading_partner.name,
                address=trading_partner.address,
                enterprise_id=trading_partner.enterprise_id.id,
            )
            for trading_partner in partners
        ]
        return response
    else:
        return permissions
