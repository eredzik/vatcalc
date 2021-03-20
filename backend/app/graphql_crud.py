import graphene
from graphene_sqlalchemy import SQLAlchemyObjectType

from . import models
from .database import db_session
from .graphql.types import Invoice, InvoiceInput, TradingPartner


class Query(graphene.ObjectType):
    all_partners = graphene.NonNull(graphene.List(graphene.NonNull(TradingPartner)))
    all_invoices = graphene.List(graphene.NonNull(Invoice))

    def resolve_all_partners(self, info):
        query = models.TradingPartner.query
        return query.all()

    def resolve_all_invoices(self, info):
        return models.Invoice.query.all()


def validate_nip(nip: str):
    if nip:
        return True
    else:
        return False


class CreateTradingPartner(graphene.Mutation):
    class Arguments:
        nip_number = graphene.NonNull(graphene.String)
        name = graphene.NonNull(graphene.String)
        adress = graphene.String()

    ok = graphene.Boolean()
    trading_partner = graphene.Field(TradingPartner)

    def mutate(root, info, nip_number, name, adress):
        ok = True
        if not validate_nip(nip_number):
            ok = False
        trading_partner = (
            db_session.query(models.TradingPartner)
            .filter(models.TradingPartner.nip_number == nip_number)
            .first()
        )
        if (not trading_partner) and ok:
            trading_partner = models.TradingPartner(
                name=name, nip_number=nip_number, adress=adress
            )
            db_session.add(trading_partner)
            db_session.commit()
            db_session.flush()
        else:
            ok = False

        return CreateTradingPartner(ok=ok, trading_partner=trading_partner)


class CreateInvoice(graphene.Mutation):
    class Arguments:
        invoice_input = InvoiceInput(required=True)

    ok = graphene.Boolean()
    invoice = graphene.Field(Invoice)
    info_output = graphene.String()

    def mutate(root, info, invoice_input):
        ok = True

        invoice = (
            db_session.query(models.Invoice)
            .filter(models.Invoice.invoice_id == invoice_input["invoice_id"])
            .first()
        )
        partner_exists = (
            db_session.query(models.TradingPartner)
            .filter(
                models.TradingPartner.nip_number
                == invoice_input["partner"]["nip_number"]
            )
            .first()
        )
        print(invoice_input)
        if (not invoice) and partner_exists:
            info_output = "Success"
            invoice = models.Invoice(
                invoice_id=invoice_input["invoice_id"],
                invoice_date=invoice_input["invoice_date"],
                invoice_type=invoice_input["invoice_type"],
                partner=partner_exists,
                invoiceposition=[
                    models.InvoicePosition(
                        name=position.name,
                        vat_rate=position.vat_rate,
                        num_items=position.num_items,
                        price_net=position.price_net,
                    )
                    for position in invoice_input["invoice_positions"]
                ],
            )
            db_session.add(invoice)
            db_session.commit()
            db_session.flush()
        elif not partner_exists:
            ok = False
            info_output = "Partner doesnt exist"
        else:
            ok = False
            info_output = "Invoice already exists"
        return CreateInvoice(ok=ok, invoice=invoice, info_output=info_output)


class Mutation(graphene.ObjectType):
    create_trading_partner = CreateTradingPartner.Field()
    create_invoice = CreateInvoice.Field()


schema = graphene.Schema(query=Query, mutation=Mutation)
