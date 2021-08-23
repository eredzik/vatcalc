module Pages.Invoices exposing (Model, Msg, page)

import Api
import Api.Data exposing (InvoiceResponse)
import Api.Request.Invoice
import Components.SimpleTable exposing (viewTable)
import Effect exposing (Effect)
import Gen.Route as Route
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
        [ div [ Attr.class "tab-container" ]
            [ div []
                [ button
                    [ Events.onClick <| SelectedTab Outbound
                    , Attr.classList
                        [ ( "active", model.invoiceTabSelected == Outbound )
                        , ( "tab", True )
                        ]
                    ]
                    [ text "Faktury zakupu" ]
                , button
                    [ Events.onClick <| SelectedTab Inbound
                    , Attr.classList
                        [ ( "active", model.invoiceTabSelected == Inbound )
                        , ( "tab", True )
                        ]
                    ]
                    [ text "Faktury sprzedaży" ]
                , button
                    [ Events.onClick <| SelectedTab All
                    , Attr.classList
                        [ ( "active", model.invoiceTabSelected == All )
                        , ( "tab", True )
                        ]
                    ]
                    [ text "Wszystkie faktury" ]
                ]
            , div [ Attr.class "tab-content-container" ]
                [ viewTable
                    [ ( "ID", .id >> String.fromInt >> text )
                    , ( "ID Faktury", .invoiceBusinessId >> text )
                    ]
                    model.invoices
                , a
                    [ Attr.class "button primary"
                    , Route.Invoices__Add
                        |> Route.toHref
                        |> Attr.href
                    ]
                    [ text "Dodaj fakturę" ]
                ]
            ]
        ]
    }
