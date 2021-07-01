import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.responses import HTMLResponse

from . import models, router
from .core.config import settings


def get_app() -> FastAPI:
    app = FastAPI(title="API")
    app.add_middleware(GZipMiddleware, minimum_size=1000)
    origins = [settings.CORS_ALLOWED_ORIGINS]
    logger = logging.getLogger("uvicorn.error")
    logger.info(f"Allowing origins: {origins=}")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.on_event("startup")
    async def startup():
        await models.database.connect()

    @app.on_event("shutdown")
    async def shutdown():
        await models.database.disconnect()

    # API section
    app.include_router(router.api_router)
    return app


app = get_app()
