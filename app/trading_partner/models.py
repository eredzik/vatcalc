from typing import Optional

from pydantic import validator
from pydantic.main import BaseModel
from tortoise import fields
from tortoise.models import Model


class TradingPartner(Model):
    id = fields.IntField(pk=True)
    nip_number = fields.TextField()
    name = fields.TextField()
    adress = fields.TextField()


class TradingPartnerIn(BaseModel):
    nip_number: str
    name: Optional[str]
    adress: Optional[str]

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
