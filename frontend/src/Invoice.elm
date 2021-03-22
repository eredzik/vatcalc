module Invoice exposing (Model, Msg(..), fetchAllInvoices, init, update, view)

import API.FetchInvoices
import API.GraphQL
import API.Objects exposing (Invoice, InvoicePosition, TradePartner)
import Backend.Enum.InvoiceType exposing (InvoiceType(..))
import Backend.Enum.VatRates exposing (VatRates(..))
import Backend.Scalar exposing (Date(..))
import Bootstrap.Grid
import Bootstrap.Table
import Graphql.Http
import Html
import RemoteData exposing (RemoteData)


type alias Model =
    { allInvoices : RemoteData (Graphql.Http.Error (Maybe (List Invoice))) (Maybe (List Invoice))
    }


init : Model
init =
    { allInvoices = RemoteData.Loading }


type Msg
    = GotAllInvoices (RemoteData (Graphql.Http.Error (Maybe (List Invoice))) (Maybe (List Invoice)))


fetchAllInvoices : Cmd Msg
fetchAllInvoices =
    API.GraphQL.makeGraphQLQuery API.FetchInvoices.getAllInvoices (RemoteData.fromResult >> GotAllInvoices)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAllInvoices response ->
            ( { model | allInvoices = response }, Cmd.none )



-- ( { model | allInvoices = response }, Cmd.none )


viewTableHeader : Bootstrap.Table.THead a
viewTableHeader =
    Bootstrap.Table.simpleThead
        [ Bootstrap.Table.th [] [ Html.text "ID" ]
        , Bootstrap.Table.th [] [ Html.text "Nazwa firmy" ]
        , Bootstrap.Table.th [] [ Html.text "Numer NIP" ]
        , Bootstrap.Table.th [] [ Html.text "Adres" ]
        ]


sumNetPositions : List InvoicePosition -> Float
sumNetPositions positions =
    let
        sumofposition position =
            position.num_items * position.price_net
    in
    List.map sumofposition positions |> List.sum


invoiceTypeToString : InvoiceType -> String
invoiceTypeToString invtype =
    case invtype of
        Received ->
            "Zakup"

        Issued ->
            "Sprzedaż"


partnerToString : TradePartner -> String
partnerToString partner =
    Maybe.withDefault "" partner.name ++ " | " ++ Maybe.withDefault "" partner.nip_number


dateToString : Date -> String
dateToString date =
    case date of
        Date payload ->
            payload


viewInvoiceRow : Invoice -> Bootstrap.Table.Row a
viewInvoiceRow invoice =
    -- case result of
    --     Nothing ->
    --         Bootstrap.Table.tr [] [ Bootstrap.Table.td [] [ Html.text "Brak faktur" ] ]
    --     Just invoice ->
    Bootstrap.Table.tr []
        [ Bootstrap.Table.td [] [ Html.text (Maybe.withDefault "Unavailable" invoice.partner.name) ]
        , Bootstrap.Table.td [] [ Html.text invoice.invoice_id ]
        , Bootstrap.Table.td [] [ Html.text <| dateToString invoice.invoice_date ]
        , Bootstrap.Table.td [] [ Html.text <| invoiceTypeToString invoice.invoice_type ]
        , Bootstrap.Table.td [] [ Html.text <| partnerToString invoice.partner ]
        , Bootstrap.Table.td [] [ Html.text <| String.fromFloat <| sumNetPositions invoice.invoiceposition ]
        ]


viewEmptyRow : Bootstrap.Table.Row a
viewEmptyRow =
    Bootstrap.Table.tr [] [ Bootstrap.Table.td [] [ Html.text "Brak faktur" ] ]


view : Model -> Bootstrap.Grid.Column msg
view model =
    let
        outbody =
            case model.allInvoices of
                RemoteData.Loading ->
                    Html.text "Wczytywanie danych ..."

                RemoteData.Success data ->
                    let
                        rows_data =
                            case data of
                                Nothing ->
                                    [ viewEmptyRow ]

                                Just datanonmiss ->
                                    List.map viewInvoiceRow datanonmiss
                    in
                    Bootstrap.Table.table
                        { options = []
                        , thead = viewTableHeader
                        , tbody = Bootstrap.Table.tbody [] rows_data
                        }

                _ ->
                    Html.text "Failed loading data"
    in
    Bootstrap.Grid.col []
        [ outbody ]
