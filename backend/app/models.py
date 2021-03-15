from sqlalchemy import Boolean, Column, Date, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship, scoped_session
from sqlalchemy.orm.relationships import RelationshipProperty

from .database import Base, SessionLocal


class Invoice(Base):
    __tablename__ = "invoice"
    uuid = Column(Integer, primary_key=True, index=True)
    invoice_id = Column(String)
    invoice_date = Column(Date)
    invoice_type = Column(String)

    invoiceposition: RelationshipProperty = relationship(
        "InvoicePosition", back_populates="invoice"
    )
    partner_id = Column(Integer, ForeignKey("tradingpartner.uuid"))
    partner: RelationshipProperty = relationship(
        "TradingPartner", back_populates="invoices"
    )


class InvoicePosition(Base):
    __tablename__ = "invoiceposition"
    uuid = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    vat_rate = Column(Float)
    num_items = Column(Float)
    price_net = Column(Float)

    invoice_id = Column(Integer, ForeignKey("invoice.uuid"))
    invoice: RelationshipProperty = relationship(
        "Invoice", back_populates="invoiceposition"
    )


class TradingPartner(Base):
    __tablename__ = "tradingpartner"
    uuid = Column(Integer, primary_key=True, index=True)
    nip_number = Column(String)
    name = Column(String)
    adress = Column(String)

    invoices: RelationshipProperty = relationship("Invoice", back_populates="partner")
