from fastapi.routing import APIRouter

from .endpoints.user import user_router

main_user_router = APIRouter()
main_user_router.include_router(user_router, prefix="/user")
