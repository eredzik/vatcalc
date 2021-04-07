from typing import List

from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.responses import HTMLResponse
from tortoise.contrib.fastapi import register_tortoise
from tortoise.contrib.pydantic import pydantic_model_creator
from typing_extensions import TypeAlias

from .database import TORTOISE_ORM
from .invoice.routers import main_invoices_router
from .trading_partner.routers import trading_partner_router
from .user.routers import main_user_router

app = FastAPI(title="API")
app.include_router(trading_partner_router, prefix="/api")
app.include_router(main_invoices_router, prefix="/api")
app.include_router(main_user_router, prefix="/api")

app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

register_tortoise(app, config=TORTOISE_ORM, add_exception_handlers=True)


@app.get("/", response_class=HTMLResponse)
async def get_index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})
