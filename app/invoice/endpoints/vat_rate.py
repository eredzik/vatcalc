from typing import List

from fastapi import APIRouter
from tortoise.contrib.pydantic import pydantic_model_creator

from ..models import VatRateCreate, VatRates

vatrates_router = APIRouter()
VatRates_Pydantic = pydantic_model_creator(VatRates)


@vatrates_router.post("/", response_model=VatRates_Pydantic)
async def create_vat_rate(schema: VatRateCreate):
    vat_rate_created = await VatRates.create(**schema.dict(exclude_unset=True))
    return await VatRates_Pydantic.from_tortoise_orm(vat_rate_created)


@vatrates_router.get("/", response_model=List[VatRates_Pydantic])  # type: ignore
async def get_vat_rates():
    return await VatRates_Pydantic.from_queryset(VatRates.all().limit(20))
