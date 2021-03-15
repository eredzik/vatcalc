-- A text input for reversing text. Very useful!
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/text_fields.html
--


module Main exposing (Model, init, main, update, view)

-- import DecoderTradePartners
--     exposing
--         ( TradePartner
--         , TradePartnerNew
--         , partnersDecoder
--         , partnersEncoder
--         )
-- import Backend.Object exposing (TradingPartner)

import API.FetchTradePartners exposing (getAllPartners)
import API.GraphQL exposing (makeGraphQLQuery)
import API.Objects exposing (TradePartner)
import Backend.Object
import Backend.Object.TradingPartner as TradingPartner
import Backend.Query as Query
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Carousel exposing (Msg)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Bootstrap.Table as Table
import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Debug exposing (toString)
import Graphql.Http exposing (HttpError)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (..)
import Html.Attributes exposing (class, href, maxlength)
import Http exposing (Response)
import Json.Decode
    exposing
        ( Decoder
        , field
        , int
        , list
        , string
        )
import Json.Encode as Encode
import Platform.Cmd
import RemoteData exposing (RemoteData, WebData)
import String exposing (length)
import Url exposing (Url)


type alias TradePartnerNew =
    { nip_number : String
    , name : String
    , adress : String
    }


type NipValidity
    = Valid
    | Invalid
    | TooShort


type alias Model =
    { key : Navigation.Key
    , url : Url.Url
    , nipValid : NipValidity
    , newTradePartner : TradePartnerNew
    , tradePartners : RemoteData (Graphql.Http.Error (List TradePartner)) (List TradePartner)
    , navbarState : Navbar.State
    }


init_trade_partner : TradePartnerNew
init_trade_partner =
    { name = ""
    , nip_number = ""
    , adress = ""
    }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
    ( { key = key
      , url = url
      , nipValid = TooShort
      , newTradePartner = init_trade_partner
      , tradePartners = RemoteData.Loading
      , navbarState = navbarState
      }
    , Platform.Cmd.batch [ fetchAllPartners, navbarCmd ]
    )


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = ClickedLink
        , onUrlChange = UrlChange
        }


type alias Flags =
    {}


type Msg
    = UpdateNIP String NipValidity
    | ClickedLink UrlRequest
    | UrlChange Url
    | GotPartnersList (RemoteData (Graphql.Http.Error (List TradePartner)) (List TradePartner))
    | NavbarMsg Navbar.State
    | UpdatePartnerData TradePartnerNew



-- | AddPartnerHttp
-- | GotAddPartnerHttpResponse (WebData TradePartner)


validateNIP : String -> Msg
validateNIP nip =
    let
        get_val number =
            String.slice number (number + 1) nip |> String.toInt |> Maybe.withDefault 0

        nipValid =
            if length nip == 10 then
                if
                    (get_val 0
                        * 6
                        + get_val 1
                        * 5
                        + get_val 2
                        * 7
                        + get_val 3
                        * 2
                        + get_val 4
                        * 3
                        + get_val 5
                        * 4
                        + get_val 6
                        * 5
                        + get_val 7
                        * 6
                        + get_val 8
                        * 7
                        |> modBy
                            11
                    )
                        == get_val 9
                then
                    Valid

                else
                    Invalid

            else
                TooShort
    in
    UpdateNIP nip nipValid


viewTradePartners : List TradePartner -> Html Msg
viewTradePartners trade_partners =
    Table.table
        { options = []
        , thead = viewTableHeader
        , tbody = Table.tbody [] (List.map viewTradePartner trade_partners)
        }


viewTradePartner : TradePartner -> Table.Row Msg
viewTradePartner trade_partner =
    Table.tr []
        [ Table.td [] [ text (toString trade_partner.id) ]
        , Table.td [] [ text (Maybe.withDefault "Unavailable" trade_partner.name) ]
        , Table.td [] [ text (Maybe.withDefault "Unavailable" trade_partner.nip_number) ]
        , Table.td [] [ text (Maybe.withDefault "Unavailable" trade_partner.adress) ]
        ]


viewTableHeader : Table.THead Msg
viewTableHeader =
    Table.simpleThead
        [ Table.th [] [ text "ID" ]
        , Table.th [] [ text "Nazwa firmy" ]
        , Table.th [] [ text "Numer NIP" ]
        , Table.th [] [ text "Adres" ]
        ]


viewTradePartnersTable : Model -> Html Msg
viewTradePartnersTable model =
    Grid.row []
        [ Grid.col []
            [ viewPartnersOrError model ]
        ]


viewPartnersOrError : Model -> Html Msg
viewPartnersOrError model =
    case model.tradePartners of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success trade_partners ->
            viewTradePartners trade_partners

        RemoteData.Failure httpError ->
            h3 [] [ text ("download failed" ++ toString httpError) ]


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


buildErrorMessage : Graphql.Http.HttpError -> String
buildErrorMessage httpError =
    case httpError of
        Graphql.Http.BadUrl message ->
            message

        Graphql.Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Graphql.Http.NetworkError ->
            "Unable to reach server."

        Graphql.Http.BadStatus metadata statusCode ->
            "Request failed with status code: " ++ statusCode ++ metadata.url ++ metadata.statusText

        Graphql.Http.BadPayload message ->
            Json.Decode.errorToString message


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateNIP nip validity ->
            let
                partner =
                    model.newTradePartner

                model_partner_new =
                    { partner | nip_number = nip }
            in
            ( { model | nipValid = validity, newTradePartner = model_partner_new }, Cmd.none )

        ClickedLink _ ->
            ( model, Cmd.none )

        UrlChange _ ->
            ( model, Cmd.none )

        GotPartnersList response ->
            ( { model | tradePartners = response }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        -- AddPartnerHttp ->
        -- ( model, createNewPartner model.newTradePartner )
        UpdatePartnerData partnerData ->
            ( { model | newTradePartner = partnerData }, Cmd.none )



-- GotAddPartnerHttpResponse _ ->
-- ( { model | newTradePartner = init_trade_partner }, getAllPartners )
-- partnersEncoder : TradePartnerNew -> Encode.Value
-- partnersEncoder trade_partner =
--     Encode.object
--         [ ( "nip_number", Encode.string trade_partner.nip_number )
--         , ( "name", Encode.string trade_partner.name )
--         , ( "adress", Encode.string trade_partner.adress )
--         ]
-- createNewPartner : TradePartnerNew -> Cmd Msg
-- createNewPartner partnerData =
--     Http.post
--         { url = "http://localhost:8000/trade_partners/"
--         , body = Http.jsonBody <| partnersEncoder partnerData
--         , expect =
--             partnersDecoder
--                 |> Http.expectJson
--                     (RemoteData.fromResult >> GotAddPartnerHttpResponse)
--         }


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


viewTradePartnerAdd : Model -> Html Msg
viewTradePartnerAdd model =
    let
        nip_validity =
            case model.nipValid of
                Valid ->
                    [ Input.success ]

                Invalid ->
                    [ Input.danger ]

                TooShort ->
                    []

        trade_partner_data =
            model.newTradePartner
    in
    Form.form []
        [ Form.group []
            [ Form.label
                []
                [ text "NIP" ]
            , Input.text
                ([ Input.id "nip"
                 , Input.attrs [ maxlength 10 ]
                 , Input.onInput validateNIP
                 , Input.value model.newTradePartner.nip_number
                 ]
                    ++ nip_validity
                )
            , Button.button [ Button.secondary ] [ text "Pobierz dane z gus" ]
            ]
        , Form.group []
            [ Form.label [] [ text "Nazwa firmy" ]
            , Input.text
                [ Input.id "name"
                , Input.onInput
                    (\value -> UpdatePartnerData { trade_partner_data | name = value })
                , Input.value model.newTradePartner.name
                ]
            ]
        , Form.group []
            [ Form.label [] [ text "Adres" ]
            , Input.text
                [ Input.id "adress"
                , Input.onInput
                    (\value -> UpdatePartnerData { trade_partner_data | adress = value })
                , Input.value model.newTradePartner.adress
                ]
            ]

        -- , Button.submitButton [ Button.primary, Button.onClick AddPartnerHttp ] [ text "Dodaj kontrahenta" ]
        ]


view : Model -> Document Msg
view model =
    { title = "Site1"
    , body =
        [ Grid.containerFluid []
            [ CDN.stylesheet
            , Navbar.config NavbarMsg
                |> Navbar.withAnimation
                |> Navbar.brand [ href "#" ] [ text "VatCalc" ]
                |> Navbar.items
                    [ Navbar.itemLink [ href "#" ] [ text "Kontrahenci" ]
                    , Navbar.itemLink [ href "#" ] [ text "Faktury" ]
                    ]
                |> Navbar.view model.navbarState
            , viewTradePartnersTable model
            , h1 [ class "text-center" ] [ text "Dodaj nową firmę" ]
            , viewTradePartnerAdd model
            ]
        ]
    }


fetchAllPartners : Cmd Msg
fetchAllPartners =
    makeGraphQLQuery getAllPartners (RemoteData.fromResult >> GotPartnersList)
