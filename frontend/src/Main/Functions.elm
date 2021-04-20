module Main.Functions exposing (..)

-- import TradingPartner.Types exposing (..)

import Browser
import Browser.Navigation
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Http exposing (header)
import Invoice.API
import Invoice.Functions
import Invoice.Types exposing (Invoice)
import Main.Types exposing (..)
import Platform.Cmd
import RemoteData exposing (WebData)
import Route exposing (Route(..), fromUrl, routeToString)
import TradingPartner.API
import TradingPartner.Functions
import TradingPartner.Types exposing (TradingPartner, TradingPartnerNew)
import Url
import Validate exposing (Validator)


type LogInDataModel
    = Email
    | Password


logInValidator : Validator ( LogInDataModel, String ) LogInData
logInValidator =
    Validate.firstError
        [ Validate.ifBlank .password ( Password, "Proszę wpisać hasło." )
        , Validate.ifBlank .email ( Email, "Proszę wpisać email" )
        , Validate.ifInvalidEmail .email (\_ -> ( Email, "Proszę wpisać poprawny email" ))
        ]


type alias LogInData =
    { email : String
    , password : String
    }


type alias Model =
    { key : Browser.Navigation.Key
    , route : Route.Route
    , tradingPartners :
        { newTradePartner : TradingPartnerNew
        , tradePartners : WebData (List TradingPartner)
        }
    , invoices :
        { allInvoices : WebData (List Invoice)
        }
    , loggedStatus : LoggedStatus
    , logInForm : LogInData
    }


init : {} -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Main.Types.Msg )
init _ url key =
    ( { key = key
      , route = fromUrl url
      , tradingPartners =
            { newTradePartner =
                { name = ""
                , nipNumber = ""
                , adress = ""
                }
            , tradePartners = RemoteData.Loading
            }
      , invoices = Invoice.Functions.init
      , loggedStatus = Visitor
      , logInForm =
            { email = ""
            , password = ""
            }
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
                    ( model, Browser.Navigation.pushUrl model.key (Url.toString url) )

                Browser.External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChange url ->
            ( { model | route = fromUrl url }, Cmd.none )

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

        Form msginner ->
            case msginner of
                EmailUpdate value ->
                    let
                        logform =
                            model.logInForm

                        new_logform =
                            { logform | email = value }
                    in
                    ( { model | logInForm = new_logform }, Cmd.none )

                PasswordUpdate value ->
                    let
                        logform =
                            model.logInForm

                        new_logform =
                            { logform | password = value }
                    in
                    ( { model | logInForm = new_logform }, Cmd.none )

                SubmitForm ->
                    let
                        validation_result =
                            Validate.validate logInValidator model.logInForm
                    in
                    case validation_result of
                        Ok _ ->
                            ( model, Cmd.none )

                        Err _ ->
                            ( model, Cmd.none )


header : Model -> Html Msg
header model =
    let
        log_buttons =
            case model.loggedStatus of
                Logged ->
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


formField : (String -> msg) -> String -> String -> String -> Html msg
formField m name t p =
    label [ class "form-label" ]
        [ text name
        , input
            [ type_ t
            , placeholder p
            , onInput m
            ]
            []
        ]


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case model.route of
                Index ->
                    text "Vatcalc"

                LogIn ->
                    div []
                        [ Html.map Form
                            (form []
                                [ formField EmailUpdate "e-mail" "text" "E-mail"
                                , formField PasswordUpdate "hasło" "password" "Hasło"
                                , button [ onClick SubmitForm ] [ text "Zaloguj" ]
                                ]
                            )
                        ]

                Register ->
                    text "Zarejestruj się!"

                LogOut ->
                    text "Wylogowałeś się!"

                Invoices ->
                    case model.loggedStatus of
                        Logged ->
                            text "Nie jesteś zalogowany - zaloguj się by wyświetlić"

                        Visitor ->
                            text "Nie jesteś zalogowany - zaloguj się by wyświetlić"

                TradePartner ->
                    TradingPartner.Functions.view model.tradingPartners
    in
    { title = "VatCalc"
    , body =
        [ header model
        , content
        ]
    }
