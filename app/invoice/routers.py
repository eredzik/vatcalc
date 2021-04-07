from app.invoice.endpoints import invoice
from fastapi import APIRouter

from .endpoints.invoice import invoice_router
from .endpoints.vat_rate import vatrates_router

main_invoices_router = APIRouter()
main_invoices_router.include_router(invoice_router, prefix="/invoice")
main_invoices_router.include_router(vatrates_router, prefix="/vat_rate")
