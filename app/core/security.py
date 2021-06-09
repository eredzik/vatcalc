from fastapi import APIRouter
from fastapi_users import FastAPIUsers, models
from fastapi_users.authentication import CookieAuthentication, JWTAuthentication
from fastapi_users.db import OrmarUserDatabase

from ..models import UserModel
from .config import settings


class User(models.BaseUser):
    pass


class UserCreate(models.BaseUserCreate):
    pass


class UserUpdate(User, models.BaseUserUpdate):
    pass


class UserDB(User, models.BaseUserDB):
    pass


user_db = OrmarUserDatabase(UserDB, UserModel)
auth_backends = []
# cookie_authentication = CookieAuthentication(
#     secret=settings.SECRET_KEY, lifetime_seconds=3600
# )
# auth_backends.append(cookie_authentication)
jwt_authentication = JWTAuthentication(
    secret=settings.SECRET_KEY, lifetime_seconds=3600, tokenUrl="/api/auth/login"
)
auth_backends.append(jwt_authentication)

fastapi_users = FastAPIUsers(
    user_db,
    auth_backends,
    User,
    UserCreate,
    UserUpdate,
    UserDB,
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
