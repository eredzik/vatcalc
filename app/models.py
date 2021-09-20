from enum import Enum

import ormar

from .core.database import database, metadata


class BaseMeta:
    database = database
    metadata = metadata


class Enterprise(ormar.Model):
    class Meta(BaseMeta):
        tablename = "enterprise"

    id = ormar.Integer(primary_key=True)
    name = ormar.String(max_length=64)
    address = ormar.String(max_length=256)
    nip_number = ormar.String(max_length=10)


class TradingPartner(ormar.Model):
    class Meta(BaseMeta):
        tablename = "tradingpartner"

    id = ormar.Integer(primary_key=True)
    nip_number = ormar.String(max_length=10)
    name = ormar.String(max_length=255)
    address = ormar.Text()
    enterprise_id = ormar.ForeignKey(Enterprise)


class InvoiceType(str, Enum):
    Inbound = "INBOUND"
    Outbound = "OUTBOUND"


class Invoice(ormar.Model):
    class Meta(BaseMeta):
        tablename = "invoice"

    id = ormar.Integer(primary_key=True)
    invoice_business_id = ormar.String(max_length=64)
    invoice_date = ormar.Date()
    invoice_type = ormar.String(max_length=8, choices=[])
    trading_partner_id = ormar.ForeignKey(TradingPartner)
    enterprise_id = ormar.ForeignKey(Enterprise)


class VatRate(ormar.Model):
    class Meta(BaseMeta):
        tablename = "vatrate"

    id = ormar.Integer(primary_key=True)
    vat_rate = ormar.Float()
    comment = ormar.String(max_length=255)
    enterprise_id = ormar.ForeignKey(Enterprise)


class InvoicePosition(ormar.Model):
    class Meta(BaseMeta):
        tablename = "invoiceposition"

    id = ormar.Integer(primary_key=True)
    name = ormar.String(max_length=50)
    vat_rate_id = ormar.ForeignKey(VatRate)
    num_items = ormar.Float()
    price_net = ormar.Float()
    invoice_id = ormar.ForeignKey(Invoice)


class User(ormar.Model):
    class Meta(BaseMeta):
        tablename = "user"

    id = ormar.Integer(primary_key=True)
    username = ormar.String(index=True, nullable=False, max_length=255, unique=True)
    email = ormar.String(index=True, unique=True, nullable=False, max_length=255)
    hashed_password = ormar.String(nullable=False, max_length=255)
    fav_enterprise_id = ormar.ForeignKey(Enterprise)
    # is_active = ormar.Boolean(default=True, nullable=False)
    # is_superuser = ormar.Boolean(default=False, nullable=False)
    # is_verified = ormar.Boolean(default=False, nullable=False)


# class UserModel(OrmarBaseUserModel):
#     class Meta(BaseMeta):
#         tablename = "users"


class UserEnterpriseRoles(str, Enum):
    viewer = "VIEWER"
    editor = "EDITOR"
    admin = "ADMIN"


class UserEnterprise(ormar.Model):
    class Meta(BaseMeta):
        tablename = "userenterprise"

    id = ormar.Integer(primary_key=True)
    enterprise_id = ormar.ForeignKey(Enterprise)
    user_id = ormar.ForeignKey(User)
    role = ormar.String(max_length=10, choices=UserEnterpriseRoles)
