from typing import List

from app.routes.auth import CurrentUser
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from starlette.status import (
    HTTP_201_CREATED,
    HTTP_409_CONFLICT,
)

from .. import models
from .utils import (
    Message,
)

vatrate_router = APIRouter(tags=["Vat Rate"])


class VatrateInput(BaseModel):
    vat_rate: float
    comment: str
    enterprise_id: int


class VatRateResponse(BaseModel):
    id: int
    vat_rate: float
    comment: str
    enterprise_id: int


@vatrate_router.post(
    "/vatrate",
    status_code=HTTP_201_CREATED,
    response_model=VatRateResponse,
    responses={
        HTTP_409_CONFLICT: {"model": Message},
    },
)
async def add_vatrate(
    vatrate: VatrateInput,
    user: models.User = Depends(
        CurrentUser(
            required_permissions=[
                models.UserEnterpriseRoles.editor,
                models.UserEnterpriseRoles.admin,
            ],
        )
    ),
):

    existing_vatrate = await models.VatRate.objects.get_or_none(
        vat_rate=vatrate.vat_rate
    )
    if existing_vatrate is None:
        created_vatrate = await models.VatRate(**vatrate.dict()).save()

        response = VatRateResponse(
            id=created_vatrate.id,
            vat_rate=created_vatrate.vat_rate,
            comment=created_vatrate.comment,
            enterprise_id=created_vatrate.enterprise_id.id,
        )
        return response
    else:
        raise HTTPException(HTTP_409_CONFLICT, detail="Entity exists")


@vatrate_router.get(
    "/vatrate",
    response_model=List[VatRateResponse],
    status_code=200,
)
async def get_vat_rates(
    page: int,
    enterprise_id: int,
    user: models.User = Depends(
        CurrentUser(
            required_permissions=[
                models.UserEnterpriseRoles.viewer,
                models.UserEnterpriseRoles.editor,
                models.UserEnterpriseRoles.admin,
            ],
        )
    ),
):
    vatrates = await models.VatRate.objects.paginate(page=page).all(
        enterprise_id=enterprise_id
    )
    response = [
        VatRateResponse(
            id=vatrate.id,
            vat_rate=vatrate.vat_rate,
            comment=vatrate.comment,
            enterprise_id=vatrate.enterprise_id.id,
        )
        for vatrate in vatrates
    ]
    return response


@vatrate_router.delete(
    "/vatrate",
    status_code=200,
)
async def delete_vatrate(
    vatrate_id: int,
    enterprise_id: int,
    user: models.User = Depends(
        CurrentUser(
            required_permissions=[
                models.UserEnterpriseRoles.editor,
                models.UserEnterpriseRoles.admin,
            ],
        )
    ),
):
    vatrate = await models.VatRate.objects.get_or_none(id=vatrate_id)
    if not vatrate:
        raise HTTPException(
            status_code=404, detail=f"Vat rate {vatrate_id} not found"
        )

    await vatrate.delete()
    return JSONResponse({"message": f"Deleted vatrate {vatrate_id}"})
