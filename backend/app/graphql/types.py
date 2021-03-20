import graphene


class TradingPartner(graphene.ObjectType):
    uuid = graphene.NonNull(graphene.Int)
    nip_number = graphene.String()
    name = graphene.String()
    adress = graphene.String()


class InvoiceType(graphene.Enum):
    received = "received"
    issued = "issued"


class VatRates(graphene.Enum):
    v_023 = 0.23
    v_08 = 0.8
    v_05 = 0.5
    v_00 = 0


class InvoicePositionInput(graphene.InputObjectType):
    name = graphene.String()
    vat_rate = VatRates()
    num_items = graphene.Float()
    price_net = graphene.Float()


class InvoicePosition(graphene.ObjectType):
    uuid = graphene.Int()
    name = graphene.String()
    vat_rate = VatRates()
    num_items = graphene.Float()
    price_net = graphene.Float()


class TradingPartnerSelection(graphene.InputObjectType):
    nip_number = graphene.String()


class InvoiceInput(graphene.InputObjectType):
    invoice_id = graphene.NonNull(graphene.String)
    invoice_date = graphene.NonNull(graphene.Date)
    invoice_type = graphene.NonNull(lambda: InvoiceType)
    partner = graphene.NonNull(TradingPartnerSelection)
    invoice_positions = graphene.List(InvoicePositionInput)


class Invoice(graphene.ObjectType):
    uuid = graphene.NonNull(graphene.Int)
    invoice_id = graphene.NonNull(graphene.String)
    invoice_date = graphene.NonNull(graphene.Date)
    # invoice_type = graphene.NonNull(graphene.Field(InvoiceType))
    # partner = graphene.NonNull(TradingPartner)
    # invoice_positions = graphene.List(InvoicePosition)
