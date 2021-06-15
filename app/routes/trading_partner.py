from typing import List

from fastapi import APIRouter, Depends, Response
from pydantic import BaseModel, validator
from starlette.status import HTTP_201_CREATED, HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT

from .. import models
from ..core.security import User, fastapi_users

tradingpartner_router = APIRouter(tags=["Trading_Partner"])


class TradingPartnerInput(BaseModel):
    nip_number: str
    name: str
    adress: str
    enterprise: int

    @validator("nip_number")
    def nip_validator(cls, nip):
        if len(nip) != 10:
            raise ValueError("Nip must have exactly 10 characters.")

        weights = [6, 5, 7, 2, 3, 4, 5, 6, 7]
        checksum_calculated = (
            sum([int(nip[i]) * weight for i, weight in enumerate(weights)]) % 11
        )
        if checksum_calculated != int(nip[9]):
            raise ValueError("Nip validation failed. Check nip number.")
        return nip


@tradingpartner_router.post(
    "/trading_partner1",
    status_code=HTTP_201_CREATED,
    response_model=models.TradingPartner,
)
async def add_trading_partner(
    trading_partner: TradingPartnerInput,
    response: Response,
    user: User = Depends(fastapi_users.current_user()),
):
    permissions = await models.UserEnterprise.objects.get_or_none(
        user_id=user.id, enterprise_id=trading_partner.enterprise
    )
    if permissions is not None:
        if permissions.role in ("EDITOR", "ADMIN"):
            existing_trading_partner = await models.TradingPartner.objects.get_or_none(
                nip_number=trading_partner.nip_number
            )
            if existing_trading_partner is not None:
                return await models.TradingPartner(**trading_partner.dict()).save()
            else:
                response.status_code = HTTP_409_CONFLICT
                return
        else:
            response.status_code = HTTP_401_UNAUTHORIZED
            return
    else:
        response.status_code = HTTP_401_UNAUTHORIZED
        return


TradingPartnerResponse = models.TradingPartner.get_pydantic(
    include={"adress", "id", "name", "nip_number"}
)


@tradingpartner_router.get(
    "/trading_partner1",
    response_model=List[TradingPartnerResponse],
)
async def get_trading_partners(
    skip: int,
    limit: int,
    enterprise_id: int,
    user: User = Depends(fastapi_users.current_user()),
):
    pass
