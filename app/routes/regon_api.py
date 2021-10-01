import os
from typing import Optional
from ..core.soap import REGONAPI
from app.routes.utils import Message
from fastapi import APIRouter, Depends
from pydantic import BaseModel, validator
from starlette import status
from pydantic.errors import PydanticValueError
from starlette.responses import JSONResponse
from starlette.status import HTTP_201_CREATED, HTTP_409_CONFLICT

from .. import models, validators
from .auth import CurrentUser, current_user_responses
from ..core.config import settings

regonapi_router = APIRouter(tags=["REGON API"])

class RegonApiResponse(BaseModel):
    regon: validators.RegonNumber
    nip: validators.NipNumber
    nip_status: Optional[str]
    company_name: str
    voivodeship: str
    powiat: str
    gmina: str
    city: str
    postal_code: str
    street: str
    house_no: str
    suite_no: Optional[str]
    type: str
    silos_id: str
    shutdown_date: str
    post_office_town: str

@regonapi_router.get(
    "/regon_api/regon_number/{regon_number}",
    status_code=200,
    responses={status.HTTP_401_UNAUTHORIZED: {"model": Message}}
)
async def get_info_by_regon(
    regon_number: str,
    user: models.User = Depends(CurrentUser())
):
    api = REGONAPI(settings.SOAP_ENDPOINT)
    token = api.login(settings.SOAP_KEY)
    response = api.request(sid=token, params={'Regon': regon_number})
    nip_output = RegonApiResponse(**response)
    return nip_output

@regonapi_router.get(
    "/regon_api/nip_number/{nip_number}",
    status_code=200,
    responses={status.HTTP_401_UNAUTHORIZED: {"model": Message}}
)
async def get_info_by_regon(
    nip_number: str,
    user: models.User = Depends(CurrentUser())
):
    api = REGONAPI(settings.SOAP_ENDPOINT)
    token = api.login(settings.SOAP_KEY)
    response = api.request(sid=token, params={'Nip': nip_number})
    nip_output = RegonApiResponse(**response)
    return nip_output
