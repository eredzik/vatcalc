from fastapi import APIRouter, Depends
from fastapi_crudrouter import OrmarCRUDRouter

from . import models
from .core.security import auth_router, fastapi_users
from .routes.enterprise import enterprise_router
from .routes.trading_partner import tradingpartner_router

api_router = APIRouter(prefix="/api")
api_router.include_router(auth_router)

# Api routes
api_router.include_router(
    OrmarCRUDRouter(
        schema=models.TradingPartner,
        delete_all_route=False,
        dependencies=[Depends(fastapi_users.current_user)],
    )
)
api_router.include_router(
    OrmarCRUDRouter(
        schema=models.Invoice,
        delete_all_route=False,
        dependencies=[Depends(fastapi_users.current_user())],
    )
)
api_router.include_router(
    OrmarCRUDRouter(
        schema=models.VatRate,
        delete_all_route=False,
        dependencies=[Depends(fastapi_users.current_user)],
    )
)
api_router.include_router(
    OrmarCRUDRouter(
        schema=models.InvoicePosition,
        delete_all_route=False,
        dependencies=[Depends(fastapi_users.current_user)],
    ),
)
api_router.include_router(
    OrmarCRUDRouter(
        schema=models.Enterprise,
        delete_all_route=False,
        dependencies=[Depends(fastapi_users.current_user)],
    ),
)
api_router.include_router(enterprise_router)
api_router.include_router(tradingpartner_router)
