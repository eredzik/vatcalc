from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.responses import HTMLResponse

from . import models, router


async def get_index(request: Request, exc=None):
    return templates.TemplateResponse("index.html", {"request": request})


app = FastAPI(title="API", exception_handlers={404: get_index})
app.add_middleware(GZipMiddleware, minimum_size=1000)


@app.on_event("startup")
async def startup():
    await models.database.connect()


@app.on_event("shutdown")
async def shutdown():
    await models.database.disconnect()


# app.include_router(router.index_router)
app.include_router(router.api_router)


# index_router = APIRouter()
# Frontend section
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")


app.get("/", response_class=HTMLResponse)(get_index)


@app.get("/", response_class=HTMLResponse)
async def get_favicon(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})
