from datetime import date
from typing import List, Literal, Optional

from pydantic import BaseModel  # pylint: disable=no-name-in-module


class InvoiceCreate(BaseModel):
    invoice_id: int
    partner_id: int
    invoice_date: date
    invoice_type: Literal["inbound", "outbound"]


class TradingPartnerBase(BaseModel):
    id: int


class TradingPartnerCreate(BaseModel):
    nip_number: str
    name: str
    adress: str


class TradingPartner(TradingPartnerBase, TradingPartnerCreate):
    class Config:
        orm_mode = True
