from pydantic import BaseModel


class TradingPartnerBase(BaseModel):
    nip_number: str
    name: str
    adress: str


class TradingPartnerCreate(TradingPartnerBase):
    pass


class TradingPartner(TradingPartnerBase):
    uuid: int

    class Config:
        orm_mode = True


class InvoiceBase(BaseModel):

    pass


class InvoiceCreate(InvoiceBase):

    pass


class Invoice(InvoiceBase):
    uuid: int