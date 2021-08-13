module Pages.Invoices exposing (Model, Msg, page)

import Api
import Api.Data exposing (InvoiceResponse)
import Api.Request.Invoice
import Components.SimpleTable exposing (simpleBootstrapTable)
import Effect exposing (Effect)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Http
import Page
import Request exposing (Request)
import Shared
import User
import View exposing (View)


type InvoiceTabSelected
    = Inbound
    | Outbound
    | All


type alias Model =
    { invoiceTabSelected : InvoiceTabSelected
    , invoices : List InvoiceResponse
    }


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\user ->
            { init = init user
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

        ReceivedData data ->
            case data of
                Ok invoices ->
                    ( { model | invoices = invoices }, Effect.none )

                Err _ ->
                    ( model, Effect.none )


type Msg
    = SelectedTab InvoiceTabSelected
    | ReceivedData (Result Http.Error (List InvoiceResponse))


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none


init : User.User -> ( Model, Effect Msg )
init user =
    ( { invoiceTabSelected = All
      , invoices = []
      }
    , Api.Request.Invoice.getInvoicesInvoiceGet 1 (Maybe.withDefault -1 user.favEnterpriseId)
        |> Api.send ReceivedData
        |> Effect.fromCmd
    )


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
                [ simpleBootstrapTable
                    [ ( "ID", True, .id >> String.fromInt )
                    , ( "ID Faktury", False, .invoiceBusinessId )
                    ]
                    model.invoices
                ]
            ]
        ]
    }
