module Invoice.Functions exposing (..)

-- import Element

import Html exposing (..)
import Invoice.Types exposing (..)
import RemoteData
import TableBuilder.TableBuilder exposing (buildTable)
import TradingPartner.Types


init : Invoice.Types.InvoiceModel
init =
    { allInvoices = RemoteData.Loading }


update : InvoiceMsg -> InvoiceModel -> ( InvoiceModel, Cmd InvoiceMsg )
update msg model =
    case msg of
        GotAllInvoices response ->
            ( { model | allInvoices = response }, Cmd.none )


sumNetPositions : List InvoicePosition -> Float
sumNetPositions positions =
    let
        sumofposition position =
            position.numItems * position.priceNet
    in
    List.map sumofposition positions |> List.sum


invoiceTypeToString : InvoiceType -> String
invoiceTypeToString invtype =
    case invtype of
        Received ->
            "Zakup"

        Issued ->
            "Sprzedaż"


partnerToString : TradingPartner.Types.TradingPartner -> String
partnerToString partner =
    partner.name ++ " | " ++ partner.nipNumber


view : InvoiceModel -> Html InvoiceMsg
view model =
    let
        outbody =
            case model.allInvoices of
                RemoteData.Loading ->
                    text "Wczytywanie danych ..."

                RemoteData.Success data ->
                    buildTable [ "header" ] [ [ "abc" ] ]

                _ ->
                    text "Failed loading data"
    in
    outbody
