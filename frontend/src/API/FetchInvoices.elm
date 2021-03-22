module API.FetchInvoices exposing (getAllInvoices)

import API.FetchTradePartners
import API.Objects exposing (Invoice, InvoicePosition)
import Backend.Object
import Backend.Object.Invoice
import Backend.Object.InvoicePosition
import Backend.Query as Query
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet


invoiceSelection : Graphql.SelectionSet.SelectionSet Invoice Backend.Object.Invoice
invoiceSelection =
    Graphql.SelectionSet.map6 Invoice
        Backend.Object.Invoice.uuid
        Backend.Object.Invoice.invoiceId
        Backend.Object.Invoice.invoiceDate
        Backend.Object.Invoice.invoiceType
        (Backend.Object.Invoice.partner
            API.FetchTradePartners.partnersSelection
        )
        (Backend.Object.Invoice.invoicePositions
            invoicePositionSelection
        )


invoicePositionSelection : Graphql.SelectionSet.SelectionSet InvoicePosition Backend.Object.InvoicePosition
invoicePositionSelection =
    Graphql.SelectionSet.map5 InvoicePosition
        Backend.Object.InvoicePosition.uuid
        Backend.Object.InvoicePosition.name
        Backend.Object.InvoicePosition.vatRate
        Backend.Object.InvoicePosition.numItems
        Backend.Object.InvoicePosition.priceNet


getAllInvoices : Graphql.SelectionSet.SelectionSet (Maybe (List Invoice)) RootQuery
getAllInvoices =
    Query.allInvoices invoiceSelection
