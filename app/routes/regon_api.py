import logging
from typing import Optional, OrderedDict, Union

import xmltodict
from app.routes.utils import Message
from fastapi import APIRouter, Depends
from fastapi.exceptions import HTTPException
from pydantic import BaseModel
from starlette import status
from zeep.client import Client

from .. import models, validators
from ..core.config import settings
from .auth import CurrentUser

regonapi_router = APIRouter(tags=["REGON API"])

gunicorn_logger = logging.getLogger("gunicorn.error")


class RegonApiSuccess(BaseModel):
    regon: Optional[validators.RegonNumber]
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
    shutdown_date: Optional[str]
    post_office_town: str


class RegonApiNotFoundFailure(BaseModel):
    error_code: str
    error_message_pl: str
    error_message_en: str
    nip_number: validators.NipNumber


@regonapi_router.get(
    "/regon_api/regon_number/{regon_number}",
    status_code=200,
    response_model=Union[RegonApiSuccess, RegonApiNotFoundFailure],
    responses={
        status.HTTP_401_UNAUTHORIZED: {"model": Message},
        status.HTTP_404_NOT_FOUND: {"model": Message},
    },
)
async def get_info_by_regon(
    regon_number: str, user: models.User = Depends(CurrentUser())
) -> Union[RegonApiSuccess, RegonApiNotFoundFailure]:

    response = query_REGON_api(
        settings.SOAP_ENDPOINT, settings.SOAP_KEY, {"Regon": regon_number}
    )
    return response


@regonapi_router.get(
    "/regon_api/nip_number/{nip_number}",
    status_code=200,
    response_model=Union[
        RegonApiSuccess,
        RegonApiNotFoundFailure,
    ],
    responses={status.HTTP_401_UNAUTHORIZED: {"model": Message}},
)
async def get_info_by_nip(
    nip_number: str, user: models.User = Depends(CurrentUser())
) -> Union[RegonApiSuccess, RegonApiNotFoundFailure]:
    response = query_REGON_api(
        settings.SOAP_ENDPOINT, settings.SOAP_KEY, {"Nip": nip_number}
    )
    return response


parsing_dict = {
    "regon": "Regon",
    "nip": "Nip",
    "nip_status": "StatusNip",
    "company_name": "Nazwa",
    "voivodeship": "Wojewodztwo",
    "powiat": "Powiat",
    "gmina": "Gmina",
    "city": "Miejscowosc",
    "postal_code": "KodPocztowy",
    "street": "Ulica",
    "house_no": "NrNieruchomosci",
    "suite_no": "NrLokalu",
    "type": "Typ",
    "silos_id": "SilosID",
    "shutdown_date": "DataZakonczeniaDzialalnosci",
    "post_office_town": "MiejscowoscPoczty",
}

parsing_error_dict = {
    "error_code": "ErrorCode",
    "error_message_pl": "ErrorMessagePl",
    "error_message_en": "ErrorMessageEn",
    "nip_number": "Nip",
}


def query_REGON_api(
    wsdl_path, key, query_params
) -> Union[RegonApiSuccess, RegonApiNotFoundFailure]:
    client = Client(wsdl_path)  # 1. Create zeep client with wsdl url
    sid = client.service.Zaloguj(
        key
    )  # 2. Pass the access key to login endpoint
    with client.settings(extra_http_headers={"sid": sid}):
        # 4. Token must be passed as a HTTP header.
        # "HTTP" is an important word here, as SOAP
        # has a damn hell of different headers.
        response: str = client.service.DaneSzukajPodmioty(
            pParametryWyszukiwania=query_params
        )

        parsed_response: Union[OrderedDict, None] = xmltodict.parse(response)
        if parsed_response is None:
            raise HTTPException(
                400, f"Response is malformed. RESPONSE = '{response}'"
            )
        elif response_body := parsed_response.get("root", {}).get("dane", {}):

            if isinstance(response_body, list):
                to_parse = response_body[0]
            elif response_body.get("Regon"):
                to_parse = response_body
            else:
                error_response_reformatted = {
                    key: response_body.get(value, None)
                    for key, value in parsing_error_dict.items()
                }
                return RegonApiNotFoundFailure(**error_response_reformatted)

            response_reformatted = {
                key: to_parse.get(value, None)
                for key, value in parsing_dict.items()
            }
            return RegonApiSuccess(**response_reformatted)
        else:
            raise HTTPException(
                400, f"Response is malformed. RESPONSE = '{response}'"
            )
