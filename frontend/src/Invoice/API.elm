module Invoice.API exposing (..)

import Http
import Invoice.Types exposing (Invoice, InvoiceMsg(..), InvoicePosition, InvoiceType(..))
import Json.Decode as JD
import RemoteData
import TradingPartner.API


invoiceTypeDecoder : JD.Decoder InvoiceType
invoiceTypeDecoder =
    JD.string
        |> JD.andThen
            (\str ->
                case str of
                    "IN" ->
                        JD.succeed Received

                    "OUT" ->
                        JD.succeed Issued

                    somethingElse ->
                        JD.fail <| "Unknown invoice type: " ++ somethingElse
            )


positionDecoder : JD.Decoder InvoicePosition
positionDecoder =
    JD.map5 InvoicePosition
        (JD.at [ "id" ] JD.int)
        (JD.at [ "name" ] JD.string)
        (JD.at [ "vatRate" ] JD.float)
        (JD.at [ "numItems" ] JD.float)
        (JD.at [ "priceNet" ] JD.float)


invoiceDecoder : JD.Decoder Invoice
invoiceDecoder =
    JD.map6 Invoice
        (JD.at [ "id" ] JD.int)
        (JD.at [ "invoice_id" ] JD.string)
        (JD.at [ "invoice_date" ] JD.string)
        (JD.at [ "invoice_type" ] invoiceTypeDecoder)
        (JD.at [ "invoice_positions" ] (JD.list positionDecoder))
        (JD.at [ "partner" ] TradingPartner.API.partnerDecoder)


invoicesDecoder : JD.Decoder (List Invoice)
invoicesDecoder =
    JD.list invoiceDecoder


fetchAllInvoices : Cmd InvoiceMsg
fetchAllInvoices =
    Http.get
        { url = "/api/invoice"
        , expect = Http.expectJson (RemoteData.fromResult >> GotAllInvoices) invoicesDecoder
        }
