import os
from typing import List

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.hash import bcrypt  # type: ignore
from tortoise.contrib.pydantic import pydantic_model_creator

from ..models import User, UserCreate, UserToken

User_Pydantic = pydantic_model_creator(User, name="User")
user_router = APIRouter()

JWT_SECRET = os.environ["JWT_SECRET"]

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


@user_router.post("/register", response_model=User_Pydantic)
async def register_user(user: UserCreate):
    user_obj = User(
        username=user.username, password_hash=bcrypt.hash(user.password_hash)
    )
    await user_obj.save()
    return await User_Pydantic.from_tortoise_orm(user_obj)


async def authenticate_user(username: str, password: str):
    user = await User.get(username=username)
    if not user:
        return False
    if not bcrypt.verify(password, user.password_hash):
        return False
    return user


@user_router.post("/login", response_model=UserToken)
async def login_user(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await authenticate_user(form_data.username, form_data.password)

    if not user:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED, detail="Invalid username or password"
        )
    user_obj = await User_Pydantic.from_tortoise_orm(user)
    token = jwt.encode(user_obj.dict(), JWT_SECRET)
    return UserToken(access_token=token)


token: str = Depends(oauth2_scheme)
