from fastapi import APIRouter

from .routes import auth, enterprise, user
from .routes.invoice import invoice_router
from .routes.trading_partner import tradingpartner_router
from .routes.vatrate import vatrate_router

api_router = APIRouter()
api_router.include_router(enterprise.get_enterprise_router())
api_router.include_router(tradingpartner_router)
api_router.include_router(vatrate_router)
api_router.include_router(invoice_router)
api_router.include_router(auth.get_auth_router())
api_router.include_router(user.get_user_router())
