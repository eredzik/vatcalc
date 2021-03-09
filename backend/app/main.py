from typing import List

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

origins = [
    "http://localhost:8001",
    "http://localhost:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/trade_partners/", response_model=schemas.TradingPartner)
def create_partner(
    partner: schemas.TradingPartnerCreate, db: Session = Depends(get_db)
):
    db_partner = crud.get_trading_partner_by_nip(db=db, nip_number=partner.nip_number)
    if db_partner:
        raise HTTPException(status_code=400, detail="Nip already exists")
    return crud.create_trading_partner(db=db, partner=partner)


@app.get("/trade_partners/", response_model=List[schemas.TradingPartner])
def read_partners(skip: int = 0, limit: int = 20, db: Session = Depends(get_db)):
    partners = crud.get_trading_partners(db, skip=skip, limit=limit)
    return partners


@app.get("/trade_partners/{partner_id}")
def read_partner(partner_id: int, db: Session = Depends(get_db)):
    db_partner = crud.get_trading_partner(db, partner_id=partner_id)
    if db_partner is None:
        raise HTTPException(status_code=404, detail="Partner not found")
    return db_partner
