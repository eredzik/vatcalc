from tortoise import fields
from tortoise.models import Model


class TradingPartner(Model):
    id = fields.IntField(pk=True)
    nip_number = fields.TextField()
    name = fields.TextField()
    adress = fields.TextField()
