from datetime import date
from typing import List, Optional

from app.routes.auth import CurrentUser
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from starlette.status import HTTP_409_CONFLICT

from .. import models

invoice_router = APIRouter(tags=["Invoice"])


class InvoicePositionInput(BaseModel):
    name: str
    vat_rate_id: int
    num_items: float
    price_net: float


class InvoiceInput(BaseModel):
    enterprise_id: int
    trading_partner_id: int
    invoice_type: models.InvoiceType
    invoice_date: date
    invoice_business_id: str
    invoicepositions: List[InvoicePositionInput]


class InvoiceUpdateResponse(BaseModel):
    enterprise_id: Optional[int] = None
    trading_partner_id: Optional[int] = None
    invoice_type: Optional[models.InvoiceType] = None
    invoice_date: Optional[date] = None
    invoice_business_id: Optional[str] = None
    invoicepositions: Optional[List[InvoicePositionInput]] = None


class InvoicePositionResponse(BaseModel):
    id: int
    name: str
    vat_rate_id: int
    num_items: float
    price_net: float


class InvoiceResponse(BaseModel):
    id: int
    enterprise_id: int
    trading_partner_id: int
    invoice_type: models.InvoiceType
    invoice_date: date
    invoice_business_id: str
    invoicepositions: List[InvoicePositionResponse]


@invoice_router.post(
    "/invoice",
    response_model=InvoiceResponse,
    status_code=201,
)
async def add_invoice(
    invoice: InvoiceInput,
    user: models.User = Depends(
        CurrentUser(
            required_permissions=[
                models.UserEnterpriseRoles.editor,
                models.UserEnterpriseRoles.admin,
            ]
        )
    ),
):
    existing_invoice = await models.Invoice.objects.get_or_none(
        invoice_business_id=invoice.invoice_business_id,
        trading_partner_id=invoice.trading_partner_id,
    )
    if existing_invoice is None:
        vatrate_exists = all(
            [
                await models.VatRate.objects.get_or_none(
                    id=pos.vat_rate_id,
                    enterprise_id=invoice.enterprise_id,
                )
                for pos in invoice.invoicepositions
            ]
        )
        if vatrate_exists:
            async with models.database.transaction():

                created = await models.Invoice(
                    invoice_business_id=invoice.invoice_business_id,
                    invoice_date=invoice.invoice_date,
                    invoice_type=invoice.invoice_type,
                    trading_partner_id=invoice.trading_partner_id,
                    enterprise_id=invoice.enterprise_id,
                ).save()
                positions = [
                    await models.InvoicePosition(
                        name=pos.name,
                        vat_rate_id=pos.vat_rate_id,
                        num_items=pos.num_items,
                        price_net=pos.price_net,
                        invoice_id=created.id,
                    ).save()
                    for pos in invoice.invoicepositions
                ]

            return InvoiceResponse(
                id=created.id,
                enterprise_id=created.enterprise_id.id,
                trading_partner_id=created.trading_partner_id.id,
                invoice_type=created.invoice_type,
                invoice_date=created.invoice_date,
                invoice_business_id=created.invoice_business_id,
                invoicepositions=[
                    InvoicePositionResponse(
                        id=pos.id,
                        name=pos.name,
                        num_items=pos.num_items,
                        price_net=pos.price_net,
                        vat_rate_id=pos.vat_rate_id.id,
                    )
                    for pos in positions
                ],
            )
        else:
            return JSONResponse(
                status_code=HTTP_409_CONFLICT,
                content={"message": "One of vat rates does not exist."},
            )


@invoice_router.get(
    "/invoice",
    response_model=InvoiceResponse,
    status_code=200,
)
async def get_invoice(
    enterprise_id: int,
    invoice_id: int,
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
    invoice = await models.Invoice.objects.get_or_none(id=invoice_id)
    if not invoice:
        raise HTTPException(
            status_code=404, detail=f"Invoice {invoice_id} not found"
        )

    invoice_output = InvoiceResponse(
        id=invoice.id,
        enterprise_id=invoice.enterprise_id.id,
        trading_partner_id=invoice.trading_partner_id.id,
        invoice_type=invoice.invoice_type,
        invoice_date=invoice.invoice_date,
        invoice_business_id=invoice.invoice_business_id,
        invoicepositions=[
            InvoicePositionResponse(
                id=pos.id,
                name=pos.name,
                num_items=pos.num_items,
                price_net=pos.price_net,
                vat_rate_id=pos.vat_rate_id.id,
            )
            for pos in invoice.invoicepositions
        ],
    )

    return invoice_output


class InvoiceListResponse(InvoiceResponse):
    trading_partner_name: str
    trading_partner_nip: str


@invoice_router.get(
    "/invoice_list",
    response_model=List[InvoiceListResponse],
    status_code=200,
)
async def get_invoice_list(
    page: int,
    enterprise_id: int,
    user: models.User = Depends(
        CurrentUser(
            required_permissions=[
                models.UserEnterpriseRoles.viewer,
                models.UserEnterpriseRoles.editor,
                models.UserEnterpriseRoles.admin,
            ]
        )
    ),
) -> List[InvoiceListResponse]:
    invoices = await (
        models.Invoice.objects.paginate(page=page)
        .select_related(["invoicepositions", "trading_partner_id"])
        .all(enterprise_id=enterprise_id)
    )
    invoices_output = [
        InvoiceListResponse(
            id=invoice.id,
            trading_partner_name=invoice.trading_partner_id.name,
            trading_partner_nip=invoice.trading_partner_id.nip_number,
            enterprise_id=invoice.enterprise_id.id,
            trading_partner_id=invoice.trading_partner_id.id,
            invoice_type=invoice.invoice_type,
            invoice_date=invoice.invoice_date,
            invoice_business_id=invoice.invoice_business_id,
            invoicepositions=[
                InvoicePositionResponse(
                    id=pos.id,
                    name=pos.name,
                    num_items=pos.num_items,
                    price_net=pos.price_net,
                    vat_rate_id=pos.vat_rate_id.id,
                )
                for pos in invoice.invoicepositions
            ],
        )
        for invoice in invoices
    ]

    return invoices_output


@invoice_router.delete(
    "/invoice",
    status_code=200,
)
async def delete_invoice(
    invoice_id: int,
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
    invoice = await models.Invoice.objects.get_or_none(id=invoice_id)
    if not invoice:
        raise HTTPException(
            status_code=404, detail=f"Invoice {invoice_id} not found"
        )

    await invoice.delete()
    return JSONResponse({"message": f"Deleted invoice {invoice_id}"})


@invoice_router.patch(
    "/invoice/{invoice_id}",
    status_code=200,
    response_model=InvoiceUpdateResponse,
)
async def update_invoice(
    invoice_id: int,
    item: InvoiceUpdateResponse,
    user: models.User = Depends(
        CurrentUser(
            required_permissions=[
                models.UserEnterpriseRoles.editor,
                models.UserEnterpriseRoles.admin,
            ],
        )
    ),
):
    invoice = await models.Invoice.objects.get_or_none(id=invoice_id)
    if not invoice:
        raise HTTPException(
            status_code=404, detail=f"Invoice {invoice_id} not found"
        )

    update_data = item.dict(exclude_unset=True)
    await invoice.update(**update_data)
    invoice_output = InvoiceResponse(
        id=invoice.id,
        enterprise_id=invoice.enterprise_id.id,
        trading_partner_id=invoice.trading_partner_id.id,
        invoice_type=invoice.invoice_type,
        invoice_date=invoice.invoice_date,
        invoice_business_id=invoice.invoice_business_id,
        invoicepositions=[
            InvoicePositionResponse(
                id=pos.id,
                name=pos.name,
                num_items=pos.num_items,
                price_net=pos.price_net,
                vat_rate_id=pos.vat_rate_id.id,
            )
            for pos in invoice.invoicepositions
        ],
    )
    return invoice_output
