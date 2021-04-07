module Invoice exposing (Model, Msg(..), fetchAllInvoices, init, update, view)

import Bootstrap.Grid
import Bootstrap.Table
import Html
import Http
import Json.Decode as JD
import Json.Encode as JE
import RemoteData exposing (WebData)
import TradePartners exposing (TradePartner)


type InvoiceType
    = Received
    | Issued


type alias Invoice =
    { id : Int
    , invoiceId : String
    , date : String
    , invoiceType : InvoiceType
    , positions : List InvoicePosition
    , partner : TradePartner
    }


type alias InvoicePosition =
    { id : Int
    , name : String
    , vatRate : Float
    , numItems : Float
    , priceNet : Float
    }


type alias Model =
    { allInvoices : WebData (List Invoice)
    }


init : Model
init =
    { allInvoices = RemoteData.Loading }


type Msg
    = GotAllInvoices (WebData (List Invoice))


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
        (JD.at [ "partner" ] TradePartners.partnerDecoder)


invoicesDecoder : JD.Decoder (List Invoice)
invoicesDecoder =
    JD.list invoiceDecoder


fetchAllInvoices : Cmd Msg
fetchAllInvoices =
    Http.get
        { url = "/api/invoice"
        , expect = Http.expectJson (RemoteData.fromResult >> GotAllInvoices) invoicesDecoder
        }


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


partnerToString : TradePartner -> String
partnerToString partner =
    Maybe.withDefault "" partner.name ++ " | " ++ Maybe.withDefault "" partner.nipNumber


viewInvoiceRow : Invoice -> Bootstrap.Table.Row a
viewInvoiceRow invoice =
    -- case result of
    --     Nothing ->
    --         Bootstrap.Table.tr [] [ Bootstrap.Table.td [] [ Html.text "Brak faktur" ] ]
    --     Just invoice ->
    Bootstrap.Table.tr []
        [ Bootstrap.Table.td [] [ Html.text (Maybe.withDefault "Unavailable" invoice.partner.name) ]
        , Bootstrap.Table.td [] [ Html.text invoice.invoiceId ]
        , Bootstrap.Table.td [] [ Html.text invoice.date ]
        , Bootstrap.Table.td [] [ Html.text <| invoiceTypeToString invoice.invoiceType ]
        , Bootstrap.Table.td [] [ Html.text <| partnerToString invoice.partner ]
        , Bootstrap.Table.td [] [ Html.text <| String.fromFloat <| sumNetPositions invoice.positions ]
        ]



-- viewEmptyRow : Bootstrap.Table.Row a
-- viewEmptyRow =
-- Bootstrap.Table.tr [] [ Bootstrap.Table.td [] [ Html.text "Brak faktur" ] ]


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
                            List.map viewInvoiceRow data
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
