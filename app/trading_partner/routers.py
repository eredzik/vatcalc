from fastapi.routing import APIRouter

from .endpoints.trading_partner import tprouter

trading_partner_router = APIRouter()
trading_partner_router.include_router(tprouter, prefix="/trading_partner")
