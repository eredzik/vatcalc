module TradePartners exposing (..)

import API.CreateNewPartner exposing (createNewPartner)
import API.FetchTradePartners exposing (getAllPartners)
import API.GraphQL exposing (makeGraphQLMutation, makeGraphQLQuery)
import API.Objects exposing (TradePartner, TradePartnerNew, TradePartnerResponse)
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid
import Bootstrap.Table
import Graphql.Http
import Html exposing (..)
import Html.Attributes
import RemoteData exposing (RemoteData)
import String


type NipValidity
    = Valid
    | Invalid
    | TooShort


validateNIP : String -> NipValidity
validateNIP nip =
    let
        get_val number =
            String.slice number (number + 1) nip |> String.toInt |> Maybe.withDefault 0

        nipValid =
            if String.length nip == 10 then
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
    nipValid


type alias Model =
    { newTradePartner : TradePartnerNew
    , tradePartners : RemoteData (Graphql.Http.Error (List TradePartner)) (List TradePartner)
    }


init : Model
init =
    { newTradePartner =
        { name = ""
        , nip_number = ""
        , adress = ""
        }
    , tradePartners = RemoteData.Loading
    }


viewTradePartners : List API.Objects.TradePartner -> Html a
viewTradePartners trade_partners =
    Bootstrap.Table.table
        { options = []
        , thead = viewTableHeader
        , tbody = Bootstrap.Table.tbody [] (List.map viewTradePartnerRow trade_partners)
        }


viewTableHeader : Bootstrap.Table.THead a
viewTableHeader =
    Bootstrap.Table.simpleThead
        [ Bootstrap.Table.th [] [ text "ID" ]
        , Bootstrap.Table.th [] [ text "Nazwa firmy" ]
        , Bootstrap.Table.th [] [ text "Numer NIP" ]
        , Bootstrap.Table.th [] [ text "Adres" ]
        ]


viewTradePartnerRow : API.Objects.TradePartner -> Bootstrap.Table.Row a
viewTradePartnerRow trade_partner =
    Bootstrap.Table.tr []
        [ Bootstrap.Table.td [] [ text (String.fromInt trade_partner.id) ]
        , Bootstrap.Table.td [] [ text (Maybe.withDefault "Unavailable" trade_partner.name) ]
        , Bootstrap.Table.td [] [ text (Maybe.withDefault "Unavailable" trade_partner.nip_number) ]
        , Bootstrap.Table.td [] [ text (Maybe.withDefault "Unavailable" trade_partner.adress) ]
        ]


type Msg
    = AddPartner
    | UpdateForm TradePartnerNew
    | GotNewPartnerResult (RemoteData (Graphql.Http.Error (Maybe TradePartnerResponse)) (Maybe TradePartnerResponse))
    | GotPartnersList (RemoteData (Graphql.Http.Error (List TradePartner)) (List TradePartner))


viewTradePartnerAdd : TradePartnerNew -> Html Msg
viewTradePartnerAdd newTradePartner =
    let
        nip_validity =
            case validateNIP newTradePartner.nip_number of
                Valid ->
                    [ Input.success ]

                Invalid ->
                    [ Input.danger ]

                TooShort ->
                    []

        trade_partner_data =
            newTradePartner
    in
    Form.form []
        [ Form.group []
            [ Form.label
                []
                [ text "NIP" ]
            , Input.text
                ([ Input.id "nip"
                 , Input.attrs [ Html.Attributes.maxlength 10 ]
                 , Input.onInput (\value -> UpdateForm { trade_partner_data | nip_number = value })
                 , Input.value newTradePartner.nip_number
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
                    (\value -> UpdateForm { trade_partner_data | name = value })
                , Input.value newTradePartner.name
                ]
            ]
        , Form.group []
            [ Form.label [] [ text "Adres" ]
            , Input.text
                [ Input.id "adress"
                , Input.onInput
                    (\value -> UpdateForm { trade_partner_data | adress = value })
                , Input.value newTradePartner.adress
                ]
            ]
        , Button.submitButton
            [ Button.primary
            , Button.onClick AddPartner
            ]
            [ text "Dodaj kontrahenta" ]
        ]


fetchAllPartners : Cmd Msg
fetchAllPartners =
    makeGraphQLQuery getAllPartners (RemoteData.fromResult >> GotPartnersList)


addNewPartner : TradePartnerNew -> Cmd Msg
addNewPartner trade_partner_data =
    makeGraphQLMutation
        (createNewPartner trade_partner_data)
        (RemoteData.fromResult >> GotNewPartnerResult)


viewTradePartnersTable : Model -> Html a
viewTradePartnersTable model =
    Bootstrap.Grid.row []
        [ Bootstrap.Grid.col []
            [ viewPartnersOrError model ]
        ]


viewPartnersOrError : Model -> Html a
viewPartnersOrError model =
    case model.tradePartners of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success trade_partners ->
            viewTradePartners trade_partners

        RemoteData.Failure _ ->
            h3 [] [ text "download failed" ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPartnersList response ->
            ( { model | tradePartners = response }, Cmd.none )

        AddPartner ->
            ( model, addNewPartner model.newTradePartner )

        UpdateForm partnerData ->
            ( { model | newTradePartner = partnerData }, Cmd.none )

        GotNewPartnerResult _ ->
            ( model, fetchAllPartners )



-- VIEW


view : Model -> Bootstrap.Grid.Column Msg
view model =
    Bootstrap.Grid.col []
        [ viewTradePartnersTable model
        , h1 [ Html.Attributes.class "text-center" ] [ text "Dodaj nową firmę" ]
        , viewTradePartnerAdd model.newTradePartner
        ]
