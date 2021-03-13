from sqlalchemy import Boolean, Column, Date, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship, scoped_session

from .database import Base, SessionLocal


class Invoice(Base):
    __tablename__ = "invoice"
    id = Column(Integer, primary_key=True, index=True)
    invoice_id = Column(String)
    invoice_date = Column(Date)
    invoice_type = Column(String)

    invoiceposition = relationship("InvoicePosition", back_populates="invoice")
    partner_id = Column(Integer, ForeignKey("tradingpartner.id"))
    partner = relationship("TradingPartner", back_populates="invoices")


class InvoicePosition(Base):
    __tablename__ = "invoiceposition"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    vat_rate = Column(Float)
    num_items = Column(Float)
    price_net = Column(Float)

    invoice_id = Column(Integer, ForeignKey("invoice.id"))
    invoice = relationship("Invoice", back_populates="invoiceposition")


class TradingPartner(Base):
    __tablename__ = "tradingpartner"
    id = Column(Integer, primary_key=True, index=True)
    nip_number = Column(String)
    name = Column(String)
    adress = Column(String)

    invoices = relationship("Invoice", back_populates="partner")
