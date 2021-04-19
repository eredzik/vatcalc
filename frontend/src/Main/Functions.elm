module Main.Functions exposing (..)

-- import TradingPartner.Types exposing (..)

import Browser
import Browser.Navigation
import Element exposing (..)
import Element.Background
import Element.Border
import Element.Region
import Invoice.API
import Invoice.Functions
import Main.Styling exposing (blue2, font, lblue)
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


header : Model -> Element Msg
header model =
    let
        logging_button =
            case model.loggedStatus of
                Logged ->
                    link [] { url = routeToString LogOut, label = text "Wyloguj" }

                Visitor ->
                    link [] { url = routeToString LogIn, label = text "Zaloguj" }
    in
    Element.row
        [ Element.Region.navigation
        , width fill
        , Element.Background.color blue2
        , spacing 10
        , padding 15
        , font
        ]
        [ el [] <|
            link []
                { url = routeToString Index
                , label =
                    image
                        [ centerX
                        , centerY
                        , Element.Border.rounded 50
                        , clip
                        , pointer
                        ]
                        { src = "static/favicon-32x32.png", description = "logo" }
                }
        , link [] { url = routeToString Invoices, label = text "Faktury" }
        , link [] { url = routeToString TradePartner, label = text "Kontrahenci" }
        , el [ alignRight ] (text "")
        , logging_button
        ]


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case fromUrl model.url of
                Index ->
                    text "1"

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
        [ Element.layout [] <|
            column [ width fill ]
                [ header model
                , el
                    [ Element.Background.color lblue
                    , width fill
                    ]
                    content
                , text <| Url.toString model.url
                ]
        ]
    }
