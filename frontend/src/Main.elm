module Main exposing (Model, init, main, update, view)

-- import DecoderTradePartners
--     exposing
--         ( TradePartner
--         , TradePartnerNew
--         , partnersDecoder
--         , partnersEncoder
--         )
-- import Backend.Object exposing (TradingPartner)

import Bootstrap.CDN as CDN
import Bootstrap.Carousel exposing (Msg)
import Bootstrap.Grid as Grid
import Browser
import Browser.Navigation
import Html exposing (..)
import Invoice exposing (fetchAllInvoices)
import Navbar
import Platform.Cmd
import Route
import TradePartners exposing (Msg(..), NipValidity(..), fetchAllPartners)
import Url


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , navbar : Navbar.Model
    , tradePartners : TradePartners.Model
    , invoices : Invoice.Model
    }


type alias Flags =
    {}


type Msg
    = UrlRequest Browser.UrlRequest
    | UrlChange Url.Url
    | NavbarMsg Navbar.Msg
    | TradePartnersMsg TradePartners.Msg
    | InvoiceMsg Invoice.Msg


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( navbarstate, navbarcmd ) =
            Navbar.init
    in
    ( { key = key
      , url = url
      , navbar = navbarstate
      , tradePartners = TradePartners.init
      , invoices = Invoice.init
      }
    , Platform.Cmd.batch
        [ Cmd.map NavbarMsg navbarcmd
        , Cmd.map TradePartnersMsg fetchAllPartners
        , Cmd.map InvoiceMsg fetchAllInvoices
        ]
    )


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }


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

        UrlChange _ ->
            -- changeRouteTo (Route.fromUrl url) model
            ( model, Cmd.none )

        NavbarMsg navmsg ->
            let
                ( navmodel, navmsgin ) =
                    Navbar.update navmsg model.navbar

                navmsgout =
                    Cmd.map NavbarMsg navmsgin
            in
            ( { model | navbar = navmodel }, navmsgout )

        TradePartnersMsg tradepartnermsg ->
            let
                ( tradepartnermodel, tradepartnercmd ) =
                    TradePartners.update tradepartnermsg model.tradePartners

                tradepartnercmdout =
                    Cmd.map TradePartnersMsg tradepartnercmd
            in
            ( { model | tradePartners = tradepartnermodel }, tradepartnercmdout )

        InvoiceMsg subMsg ->
            let
                ( outmodel, cmd ) =
                    Invoice.update subMsg model.invoices

                outcmd =
                    Cmd.map InvoiceMsg cmd
            in
            ( { model | invoices = outmodel }, outcmd )


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


view : Model -> Document Msg
view model =
    let
        viewTradePartners =
            Html.map TradePartnersMsg
                (Grid.row []
                    [ TradePartners.view model.tradePartners
                    ]
                )

        viewInvoices =
            Html.map InvoiceMsg
                (Grid.row []
                    [ Invoice.view model.invoices
                    ]
                )

        view_all =
            case Route.fromUrl model.url of
                Nothing ->
                    viewTradePartners

                Just Route.Invoices ->
                    viewInvoices

                Just Route.TradePartner ->
                    viewTradePartners
    in
    { title = "Site1"
    , body =
        [ Grid.containerFluid []
            [ CDN.stylesheet
            , Html.map NavbarMsg (Navbar.view model.navbar)
            , view_all
            ]
        ]
    }
