import databases
import ormar
import sqlalchemy
from fastapi_users.db import OrmarBaseUserModel, OrmarUserDatabase

from .core.config import settings

database = databases.Database(str(settings.SQLALCHEMY_DATABASE_URI))
metadata = sqlalchemy.MetaData()


class BaseMeta:
    database = database
    metadata = metadata


class Enterprise(ormar.Model):
    class Meta(BaseMeta):
        tablename = "enterprise"

    id = ormar.Integer(primary_key=True)
    name = ormar.String(max_length=64)


class TradingPartner(ormar.Model):
    class Meta(BaseMeta):
        tablename = "tradingpartner"

    id = ormar.Integer(primary_key=True)
    nip_number = ormar.String(max_length=10)
    name = ormar.String(max_length=255)
    adress = ormar.Text()
    enterprise = ormar.ForeignKey(Enterprise)


class Invoice(ormar.Model):
    class Meta(BaseMeta):
        tablename = "invoice"

    id = ormar.Integer(primary_key=True)
    invoice_id = ormar.String(max_length=64)
    invoice_date = ormar.Date()
    invoice_type = ormar.String(max_length=8, choices=["INBOUND", "OUTBOUND"])
    trading_partner = ormar.ForeignKey(TradingPartner)
    enterprise = ormar.ForeignKey(Enterprise)


class VatRate(ormar.Model):
    class Meta(BaseMeta):
        tablename = "vatrate"

    id = ormar.Integer(primary_key=True)
    vat_rate = ormar.Float()
    comment = ormar.String(max_length=255)
    enterprise = ormar.ForeignKey(Enterprise)


class InvoicePosition(ormar.Model):
    class Meta(BaseMeta):
        tablename = "invoiceposition"

    id = ormar.Integer(primary_key=True)
    name = ormar.String(max_length=50)
    vat_rate = ormar.ForeignKey(VatRate)
    num_items = ormar.Float()
    price_net = ormar.Float()
    invoice = ormar.ForeignKey(Invoice)


class UserModel(OrmarBaseUserModel):
    class Meta:
        tablename = "users"
        metadata = metadata
        database = database
