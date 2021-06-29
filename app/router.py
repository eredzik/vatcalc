from fastapi import APIRouter, Depends
from fastapi_crudrouter import OrmarCRUDRouter

from . import models
from .core.security import auth_router, fastapi_users
from .routes.enterprise import enterprise_router
from .routes.invoice import invoice_router
from .routes.trading_partner import tradingpartner_router
from .routes.vatrate import vatrate_router

api_router = APIRouter(prefix="/api")
api_router.include_router(auth_router)

api_router.include_router(enterprise_router)
api_router.include_router(tradingpartner_router)
api_router.include_router(vatrate_router)
api_router.include_router(invoice_router)
