module Main.Functions exposing (..)

-- import TradingPartner.Types exposing (..)

import Browser
import Browser.Navigation
import Html exposing (..)
import Html.Attributes
import Invoice.API
import Invoice.Functions
import Main.Types exposing (..)
import Platform.Cmd
import Route exposing (Route(..), fromUrl, routeToString)
import TradingPartner.API
import TradingPartner.Functions
import Url


init : Main.Types.Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Main.Types.Msg )
init _ url key =
    ( { key = key
      , url = url
      , tradingPartners = TradingPartner.Functions.init
      , invoices = Invoice.Functions.init
      , loggedStatus = Visitor
      }
    , Platform.Cmd.batch
        [ Cmd.map Main.Types.TradingPartnerMsg TradingPartner.API.fetchAllPartners
        , Cmd.map Main.Types.InvoiceMsg Invoice.API.fetchAllInvoices
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( { model | url = url }, Browser.Navigation.pushUrl model.key (Url.toString url) )

                Browser.External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChange url ->
            ( { model | url = url }, Cmd.none )

        TradingPartnerMsg tradepartnermsg ->
            let
                ( tradepartnermodel, cmd ) =
                    TradingPartner.Functions.update tradepartnermsg model.tradingPartners

                outmsg =
                    Cmd.map TradingPartnerMsg cmd
            in
            ( { model | tradingPartners = tradepartnermodel }, outmsg )

        InvoiceMsg subMsg ->
            let
                ( outmodel, cmd ) =
                    Invoice.Functions.update subMsg model.invoices

                outmsg =
                    Cmd.map InvoiceMsg cmd
            in
            ( { model | invoices = outmodel }, outmsg )


header : Model -> List (Html Msg)
header model =
    let
        log_button =
            case model.loggedStatus of
                Logged ->
                    li [ Html.Attributes.href <| routeToString LogOut ] [ text "Wyloguj" ]

                Visitor ->
                    li [ Html.Attributes.href <| routeToString LogIn ] [ text "Zaloguj" ]
    in
    [ li [ Html.Attributes.href <| routeToString Index ]
        [ img
            [ Html.Attributes.src "static/favicon-32x32.png"
            ]
            [ text "somedescription" ]
        ]
    , li [ Html.Attributes.href <| routeToString Invoices ] [ text "Faktury" ]
    , li [ Html.Attributes.href <| routeToString TradePartner ] [ text "Kontrahenci" ]
    , log_button
    ]


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case fromUrl model.url of
                Index ->
                    text "1 "

                LogIn ->
                    text "2"

                LogOut ->
                    text "3"

                Invoices ->
                    text "4"

                TradePartner ->
                    TradingPartner.Functions.view model.tradingPartners
    in
    { title = "VatCalc"
    , body =
        [ nav []
            [ ul []
                (header
                    model
                )
            ]
        , div [] [ content ]
        ]
    }
