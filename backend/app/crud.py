from sqlalchemy.orm import Session

from . import models, schemas


def get_trading_partner(db: Session, partner_id: int):
    return (
        db.query(models.TradingPartner)
        .filter(models.TradingPartner.id == partner_id)
        .first()
    )


def get_trading_partner_by_nip(db: Session, nip_number: str):
    return (
        db.query(models.TradingPartner)
        .filter(models.TradingPartner.nip_number == nip_number)
        .first()
    )


def get_trading_partners(db: Session, skip: int = 0, limit: int = 20):
    return db.query(models.TradingPartner).offset(skip).limit(limit).all()


def create_trading_partner(db: Session, partner: schemas.TradingPartnerCreate):
    db_partner = models.TradingPartner(
        nip_number=partner.nip_number, name=partner.name, adress=partner.adress
    )
    db.add(db_partner)
    db.commit()
    db.refresh(db_partner)
    return db_partner
