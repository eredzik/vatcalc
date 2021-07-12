from fastapi import FastAPI
from fastapi.middleware.gzip import GZipMiddleware

from . import models, router


def get_app() -> FastAPI:
    app = FastAPI(
        title="API",
        root_path="/api",
    )
    app.add_middleware(GZipMiddleware, minimum_size=1000)

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
