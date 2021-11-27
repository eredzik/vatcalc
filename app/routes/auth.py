from datetime import datetime, timedelta
from json.decoder import JSONDecodeError
from typing import List, Union

import jwt
from fastapi import APIRouter, Request, Response
from fastapi.exceptions import HTTPException
from passlib.context import CryptContext
from pydantic import EmailStr
from pydantic.main import BaseModel
from starlette.responses import JSONResponse
from starlette.status import (
    HTTP_201_CREATED,
    HTTP_204_NO_CONTENT,
    HTTP_401_UNAUTHORIZED,
    HTTP_403_FORBIDDEN,
    HTTP_409_CONFLICT,
)

from .. import models
from ..core.config import settings
from ..models import User
from .utils import Message

ALGORITHM = "HS256"


def get_auth_router():
    SESSION_COOKIE_KEY = "session"
    auth_router = APIRouter(tags=["Authentication"])
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    class LoginInput(BaseModel):
        username: str
        password: str

    @auth_router.post(
        "/login",
        status_code=HTTP_204_NO_CONTENT,
        responses={HTTP_401_UNAUTHORIZED: {"model": Message}},
    )
    async def login_user(response: Response, login_input: LoginInput):
        user = await User.objects.get_or_none(username=login_input.username)
        if user is None:
            return JSONResponse(
                Message(detail="User not found.").json(),
                status_code=HTTP_401_UNAUTHORIZED,
            )
        verified, updated_password_hash = pwd_context.verify_and_update(
            login_input.password, user.hashed_password
        )

        if not verified:
            return None
        # Update password hash to a more robust one if needed
        if updated_password_hash is not None:
            user.hashed_password = updated_password_hash
            await user.update()

        expire_date = datetime.utcnow() + timedelta(
            seconds=settings.ACCESS_TOKEN_EXPIRE_SECONDS
        )
        payload = {
            "user_id": user.id,
            "username": login_input.username,
            "exp": expire_date,
        }
        jwt_encoded = jwt.encode(
            payload, settings.JWT_SECRET, algorithm=ALGORITHM
        )
        response.set_cookie(
            key=SESSION_COOKIE_KEY,
            value=jwt_encoded,  # type: ignore
            expires=settings.ACCESS_TOKEN_EXPIRE_SECONDS,
            secure=True,
            httponly=True,
            samesite="Lax",
        )
        response.status_code = HTTP_204_NO_CONTENT
        return response

    class RegisterResponse(BaseModel):
        email: str

    class RegisterInput(BaseModel):
        username: str
        email: EmailStr
        password: str

    @auth_router.post(
        "/register",
        response_model=RegisterResponse,
        status_code=HTTP_201_CREATED,
    )
    async def register_user(input_data: RegisterInput):
        if await User.objects.get_or_none(
            username=input_data.username, email=input_data.email
        ):
            raise HTTPException(HTTP_409_CONFLICT, "User exists")

        new_user = await User(
            username=input_data.username,
            hashed_password=pwd_context.hash(input_data.password),
            email=input_data.email,
        ).save()
        return new_user

    @auth_router.post(
        "/logout",
        status_code=HTTP_204_NO_CONTENT,
        responses={HTTP_401_UNAUTHORIZED: {"model": Message}},
    )
    async def logout(response: Response):
        response.delete_cookie(SESSION_COOKIE_KEY)
        response.status_code = HTTP_204_NO_CONTENT
        return response

    return auth_router


class CookieUnauthorizedError(HTTPException):
    def __init__(self):
        super().__init__(
            status_code=HTTP_401_UNAUTHORIZED,
            detail={"message1": "Token is invalid."},
        )


def current_user_responses():
    return {HTTP_401_UNAUTHORIZED: {"model": Message}}


class CurrentUser:
    def __init__(
        self,
        required_permissions: Union[
            None, List[models.UserEnterpriseRoles]
        ] = None,
    ):
        self.required_permissions = required_permissions

    async def __call__(self, request: Request):
        try:
            session = request.cookies.get("session", "")
            payload_decoded: dict = jwt.decode(
                session, settings.JWT_SECRET, algorithms=[ALGORITHM]
            )
            expiration = datetime.fromtimestamp(payload_decoded.get("exp", 0))
            if expiration < datetime.now():
                raise CookieUnauthorizedError
            user_id = payload_decoded.get("user_id")
            if user_id is None:
                return None
        except jwt.PyJWTError:
            raise CookieUnauthorizedError
        user_in_db = await User.objects.get_or_none(id=user_id)
        if not user_in_db:
            raise CookieUnauthorizedError

        if self.required_permissions is not None:
            if request.method in (
                "DELETE",
                "GET",
            ):
                request_body = {}
            else:
                try:
                    request_body = await request.json()
                except JSONDecodeError:
                    request_body = {}

            enterpise_id = (
                request_body.get("enterprise_id")
                or request.path_params.get("enterprise_id")
                or request.query_params.get("enterprise_id")
            )
            if not enterpise_id:
                raise CookieUnauthorizedError

            permissions = await models.UserEnterprise.objects.get_or_none(
                user_id=user_in_db, enterprise_id=enterpise_id
            )
            if permissions is None:
                raise HTTPException(
                    status_code=HTTP_403_FORBIDDEN,
                    detail="Unauthorized",
                )
            elif permissions.role not in (
                r.value for r in self.required_permissions
            ):
                raise HTTPException(
                    status_code=HTTP_403_FORBIDDEN, detail="Unauthorized"
                )
            else:
                return user_in_db
        return user_in_db
