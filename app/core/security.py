# from datetime import datetime, timedelta
# from typing import Any, Union

# from jose import jwt
# from passlib.context import CryptContext

# from .config import settings

# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ALGORITHM = "HS256"


# def create_access_token(
#     subject: Union[str, Any], expires_delta: timedelta = None
# ) -> str:
#     if expires_delta:
#         expire = datetime.utcnow() + expires_delta
#     else:
#         expire = datetime.utcnow() + timedelta(
#             minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
#         )
#     to_encode = {"exp": expire, "sub": str(subject)}
#     encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
#     return encoded_jwt


# def verify_password(plain_password: str, hashed_password: str) -> bool:
#     return pwd_context.verify(plain_password, hashed_password)


# def get_password_hash(password: str) -> str:
#     return pwd_context.hash(password)

from fastapi_users import FastAPIUsers, models
from fastapi_users.authentication import CookieAuthentication, JWTAuthentication
from fastapi_users.db import OrmarUserDatabase

# from .. import models
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
    secret=settings.SECRET_KEY, lifetime_seconds=3600
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
