module Pages.Invoices exposing (Model, Msg, page)

import Api.Invoice exposing (Invoice)
import Components.SimpleTable exposing (simpleBootstrapTable)
import Effect exposing (Effect)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


type alias Model =
    { invoiceTabSelected : InvoiceTabSelected
    , inboundInvoices : List Invoice
    , outboundInvoices : List Invoice
    }


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\_ ->
            { init = init shared
            , update = update req
            , subscriptions = subscriptions
            , view = view shared
            }
        )


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
                        simpleBootstrapTable
                            [ ( "ID", True, .id )
                            , ( "Numer NIP", False, .nipNumber )
                            ]
                            model.inboundInvoices

                    Outbound ->
                        simpleBootstrapTable
                            [ ( "ID", True, .id )
                            , ( "Numer NIP", False, .nipNumber )
                            ]
                            model.outboundInvoices
                ]
            ]
        ]
    }
