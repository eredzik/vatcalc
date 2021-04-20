from fastapi import APIRouter, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi_crudrouter import OrmarCRUDRouter
from starlette.responses import HTMLResponse

from . import models
from .core.security import fastapi_users, jwt_authentication

api_router = APIRouter(prefix="/api")
# Api routes
api_router.include_router(
    OrmarCRUDRouter(schema=models.TradingPartner, delete_all_route=False)
)
api_router.include_router(
    OrmarCRUDRouter(schema=models.Invoice, delete_all_route=False)
)
api_router.include_router(
    OrmarCRUDRouter(schema=models.VatRate, delete_all_route=False)
)
api_router.include_router(
    OrmarCRUDRouter(schema=models.InvoicePosition, delete_all_route=False),
)

api_router.include_router(
    OrmarCRUDRouter(schema=models.Enterprise, delete_all_route=False),
)


# Authentication routers
auth_router = APIRouter()
auth_router.include_router(
    fastapi_users.get_auth_router(jwt_authentication),
    prefix="/auth",
    tags=["auth"],
)
auth_router.include_router(
    fastapi_users.get_register_router(),
    prefix="/auth",
    tags=["auth"],
)
api_router.include_router(auth_router)
