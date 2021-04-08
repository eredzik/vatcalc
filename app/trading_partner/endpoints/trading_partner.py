from typing import List

from fastapi import APIRouter
from tortoise.contrib.pydantic import pydantic_model_creator

from ..models import TradingPartner, TradingPartnerIn

tprouter = APIRouter()

TradingPartner_Pydantic = pydantic_model_creator(TradingPartner, name="TradingPartner")


@tprouter.get("/", response_model=List[TradingPartner_Pydantic])  # type: ignore
async def get_trading_partners():
    return await TradingPartner_Pydantic.from_queryset(TradingPartner.all().limit(20))


@tprouter.post("/", response_model=TradingPartner_Pydantic)
async def create_trading_partner(
    trading_partner_in: TradingPartnerIn,  # type: ignore
):
    trading_partner_obj = await TradingPartner.create(
        **trading_partner_in.dict(exclude_unset=True)  # type: ignore
    )
    return await TradingPartner_Pydantic.from_tortoise_orm(trading_partner_obj)
