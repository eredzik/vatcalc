from datetime import date
from enum import Enum
from typing import List

from pydantic import BaseModel
from tortoise import fields
from tortoise.models import Model

from ..trading_partner.models import TradingPartner


class InvoiceType(Enum):
    Inbound = "IN"
    Outbound = "OUT"


class Invoice(Model):
    id = fields.IntField(pk=True)
    invoice_id = fields.CharField(50)
    invoice_date = fields.DateField()
    invoice_type = fields.CharEnumField(InvoiceType)
    invoice_positions: fields.ReverseRelation["InvoicePosition"]
    partner: fields.ForeignKeyRelation[TradingPartner] = fields.ForeignKeyField("models.TradingPartner", related_name="invoices")  # type: ignore


class VatRates(Model):
    id = fields.IntField(pk=True)
    vat_rate = fields.FloatField()
    comment = fields.CharField(200)


class VatRateCreate(BaseModel):
    vat_rate: float
    comment: str


class VatRateChoice(BaseModel):
    id: int


class InvoicePositionCreate(BaseModel):
    name: str
    vat_rate: VatRateChoice
    num_items: float
    price_net: float


class InvoiceCreate(BaseModel):
    invoice_id: str
    invoice_date: date
    invoice_type: InvoiceType
    invoice_positions: List[InvoicePositionCreate]


class InvoicePosition(Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(200)
    vat_rate: fields.ForeignKeyRelation[VatRates] = fields.ForeignKeyField("models.VatRates", related_name="positions")  # type: ignore
    num_items = fields.FloatField()
    price_net = fields.FloatField()
    invoice: fields.ForeignKeyRelation[Invoice] = fields.ForeignKeyField(
        "models.Invoice", related_name="positions"
    )  # type: ignore
