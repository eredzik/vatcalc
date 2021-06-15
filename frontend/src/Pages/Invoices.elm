module Pages.Invoices exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


type alias Invoice =
    { id : String
    , nipNumber : String
    }


type alias Model =
    { invoiceTabSelected : InvoiceTabSelected
    , inboundInvoices : List Invoice
    , outboundInvoices : List Invoice
    }


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared
        , update = update req
        , subscriptions = subscriptions
        , view = view shared
        }


update : Request -> Msg -> Model -> ( Model, Effect msg )
update _ msg model =
    case msg of
        SelectedTab tab ->
            ( { model | invoiceTabSelected = tab }, Effect.none )

        ReceivedInvoices ->
            ( model, Effect.none )


type Msg
    = SelectedTab InvoiceTabSelected
    | ReceivedInvoices


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { invoiceTabSelected = Inbound
      , inboundInvoices =
            [ Invoice "1" "Przychodzaca"
            ]
      , outboundInvoices =
            [ Invoice "3" "Wychodzaca"
            ]
      }
    , Effect.none
    )


type InvoiceTabSelected
    = Inbound
    | Outbound


view : Shared.Model -> Model -> View Msg
view _ model =
    { title = "Rejestr VAT"
    , body =
        [ div []
            [ ul [ Attr.classList [ ( "nav", True ), ( "nav-pills", True ) ] ]
                [ li
                    [ Attr.classList
                        [ ( "nav-item", True )
                        ]
                    ]
                    [ a
                        [ Events.onClick <| SelectedTab Inbound
                        , Attr.href "#"
                        , Attr.classList
                            [ ( "active", model.invoiceTabSelected == Inbound )
                            , ( "nav-link", True )
                            ]
                        ]
                        [ text "Faktury zakupu" ]
                    ]
                , li
                    [ Attr.classList
                        [ ( "nav-item", True )
                        ]
                    ]
                    [ a
                        [ Events.onClick <| SelectedTab Outbound
                        , Attr.href "#"
                        , Attr.classList
                            [ ( "active", model.invoiceTabSelected == Outbound )
                            , ( "nav-link", True )
                            ]
                        ]
                        [ text "Faktury sprzedaży" ]
                    ]
                ]
            , div []
                [ case model.invoiceTabSelected of
                    Inbound ->
                        showTable model.inboundInvoices

                    Outbound ->
                        showTable model.outboundInvoices
                ]
            ]
        ]
    }


showTable : List Invoice -> Html Msg
showTable invoices =
    { headers =
        [ { name = "ID", isKey = True }
        , { name = "Numer NIP", isKey = False }
        ]
    , rows = List.map (\a -> [ a.id, a.nipNumber ]) invoices
    }
        |> verifyTable
        |> bootstapTable


type alias Table =
    { headers :
        List
            { name : String
            , isKey : Bool
            }
    , rows : List (List String)
    }


type Validated a
    = Valid a
    | Invalid a
    | Empty a


verifyTable : Table -> Validated Table
verifyTable table =
    if List.all (\a -> List.length table.headers == List.length a) table.rows then
        Valid table

    else if List.length table.rows == 0 then
        Empty table

    else
        Invalid table


tableHeader : Table -> Html Msg -> Html Msg
tableHeader tab content =
    table (List.map Attr.class [ "table", "table-striped" ])
        [ thead []
            [ tr []
                (List.map
                    (\column ->
                        th
                            [ Attr.scope "col" ]
                            [ text column.name ]
                    )
                    tab.headers
                )
            ]
        , content
        ]


bootstapTable : Validated Table -> Html Msg
bootstapTable table_input =
    let
        show_row is_key row_value =
            if is_key then
                th [ Attr.scope "row" ] [ text row_value ]

            else
                td [] [ text row_value ]
    in
    case table_input of
        Valid table_valid ->
            tableHeader table_valid
                (tbody []
                    (List.map
                        (\row ->
                            tr [] <|
                                List.map2
                                    (\column_attrs row_value -> show_row column_attrs.isKey row_value)
                                    table_valid.headers
                                    row
                        )
                        table_valid.rows
                    )
                )

        Invalid _ ->
            text "Otrzymano niepoprawne dane."

        Empty table_empty ->
            tableHeader table_empty (text "")
