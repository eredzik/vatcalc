from typing import List

from fastapi import APIRouter
from tortoise.contrib.pydantic import pydantic_model_creator

from ..models import Invoice, InvoiceCreate, VatRates

invoice_router = APIRouter()


Invoice_Pydantic = pydantic_model_creator(Invoice)
VatRates_Pydantic = pydantic_model_creator(VatRates)


@invoice_router.get("/api/invoice", response_model=List[Invoice_Pydantic])  # type: ignore
async def get_all_invoices():
    return await Invoice_Pydantic.from_queryset(Invoice.all().limit(20))


@invoice_router.post("/api/invoice", response_model=Invoice_Pydantic)
async def create_invoice(schema: InvoiceCreate):
    invoice_exists = await Invoice.get(invoice_id=schema.invoice_id)
    if not invoice_exists:
        invoice_created = await Invoice.create(**schema.dict(exclude_unset=True))
        return await Invoice_Pydantic.from_tortoise_orm(invoice_created)
    return await invoice_exists
