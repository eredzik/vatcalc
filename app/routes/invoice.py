from datetime import date
from typing import List, Type

from fastapi import APIRouter, Depends, Response
from fastapi.responses import JSONResponse
from ormar.fields.model_fields import JSON
from pydantic import BaseModel, validator
from starlette.status import HTTP_201_CREATED, HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT

from .. import models, validators
from ..core.security import User, fastapi_users
from .utils import (
    Message,
    get_verify_enterprise_permissions_responses,
    verify_enterprise_permissions,
)

invoice_router = APIRouter(tags=["Invoice"])

vatrate_input: Type[models.VatRate] = models.VatRate.get_pydantic(
    exclude={"enterprise", "invoicepositions"}
)  # type: ignore


class InvoicePositionInput(BaseModel):
    name: str
    vat_rate: vatrate_input
    num_items: float
    price_net: float


trading_partner_input: Type[models.TradingPartner] = models.TradingPartner.get_pydantic(
    exclude={"invoices"}
)  # type: ignore


class InvoiceInput(BaseModel):
    invoice_type: models.InvoiceType
    invoice_date: date
    trading_partner: trading_partner_input
    invoice_id: str
    invoicepositions: List[InvoicePositionInput]


@invoice_router.post(
    "/invoice",
    response_model=models.Invoice,
    responses={**get_verify_enterprise_permissions_responses()},
    status_code=201,
)
async def add_invoice(
    invoice: InvoiceInput, user: User = Depends(fastapi_users.current_user())
):
    permissions = await verify_enterprise_permissions(
        user,
        invoice.trading_partner.enterprise.id,
        required_permissions=[
            models.UserEnterpriseRoles.editor,
            models.UserEnterpriseRoles.admin,
        ],
    )
    if permissions is True:
        existing_invoice = await models.Invoice.objects.get_or_none(
            invoice_id=invoice.invoice_id, trading_partner=invoice.trading_partner.id
        )
        if existing_invoice is None:
            vatrate_exists = all(
                [
                    await models.VatRate.objects.get_or_none(
                        id=pos.vat_rate.dict().get("id"),
                        enterprise=invoice.trading_partner.id,
                    )
                    for pos in invoice.invoicepositions
                ]
            )
            if vatrate_exists:
                async with models.database.transaction() as transaction:
                    created = await models.Invoice(
                        **invoice.dict(),
                        enterprise=invoice.trading_partner.enterprise.id
                    ).save()
                    # for pos in invoice.invoice_positions:
                    #     await models.InvoicePosition(
                    #         **pos.dict(), invoice=created.id
                    #     ).save()

                return created
            else:
                return JSONResponse(
                    status_code=HTTP_409_CONFLICT,
                    content={"message": "One of vat rates does not exist."},
                )
    else:
        return permissions


@invoice_router.get(
    "/invoice",
    response_model=List[models.Invoice],
    status_code=200,
    responses={**get_verify_enterprise_permissions_responses()},
)
async def get_invoices(
    page: int,
    enterprise_id: int,
    user: User = Depends(fastapi_users.current_user()),
):
    permissions = await verify_enterprise_permissions(
        user,
        enterprise_id,
        required_permissions=[
            models.UserEnterpriseRoles.viewer,
            models.UserEnterpriseRoles.editor,
            models.UserEnterpriseRoles.admin,
        ],
    )
    if permissions is True:
        invoices = await models.Invoice.objects.paginate(page=page).all(
            enterprise__id=enterprise_id
        )
        return invoices
    else:
        return permissions
