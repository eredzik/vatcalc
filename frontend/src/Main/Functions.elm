module Main.Functions exposing (..)

-- import TradingPartner.Types exposing (..)

import Browser
import Browser.Navigation
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Http exposing (header)
import Invoice.Functions
import LogIn.Functions
import Main.Types exposing (Model, Msg(..))
import Register.Functions
import Register.Types exposing (RegisterMsg(..))
import Route exposing (Route(..), routeToString)
import SiteState.Types exposing (LoggedStatus(..))
import TradingPartner.Functions
import Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.key (Url.toString url) )

                Browser.External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChange url ->
            ( { model | route = Route.fromUrl url }, Cmd.none )

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

        LogInMsg subMsg ->
            let
                ( outmodel, cmd ) =
                    LogIn.Functions.update subMsg model.logInModel

                outmsg =
                    Cmd.map LogInMsg cmd
            in
            ( { model | logInModel = outmodel }, outmsg )

        RegisterMsg subMsg ->
            let
                ( outmodel, cmd ) =
                    Register.Functions.update subMsg model.registerModel model.key

                outmsg =
                    Cmd.map RegisterMsg cmd
            in
            ( { model | registerModel = outmodel }, outmsg )


header : Model -> Html Msg
header model =
    let
        log_buttons =
            case model.siteState.loggedStatus of
                Logged _ ->
                    [ a
                        [ Html.Attributes.href <| routeToString LogOut ]
                        [ text "Wyloguj" ]
                    ]

                Visitor ->
                    [ a
                        [ Html.Attributes.href <| routeToString LogIn ]
                        [ text "Zaloguj" ]
                    , a [ Html.Attributes.href <| routeToString Register ] [ text "Zarejestruj się" ]
                    ]
    in
    div [ class "navigation-bar" ]
        [ div [ id "navigation-container" ]
            [ img
                [ Html.Attributes.src "static/android-chrome-192x192.png"
                , Html.Attributes.href <| routeToString Index
                , class "logo"
                ]
                [ text "somedescription" ]
            , ul []
                [ li [] log_buttons
                ]
            ]
        ]


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case model.route of
                Index ->
                    text "Vatcalc"

                LogIn ->
                    Html.map LogInMsg (LogIn.Functions.view model.logInModel)

                Register ->
                    Html.map RegisterMsg (Register.Functions.view model.registerModel)

                LogOut ->
                    text "Wylogowałeś się!"

                Invoices ->
                    Html.map InvoiceMsg (Invoice.Functions.view model.invoices model.siteState)

                TradePartner ->
                    TradingPartner.Functions.view model.tradingPartners
    in
    { title = "VatCalc"
    , body =
        [ header model
        , content
        ]
    }
