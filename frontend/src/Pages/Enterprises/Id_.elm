module Pages.Enterprises.Id_ exposing (Model, Msg, page)

import Api
import Api.Data exposing (VatRateResponse)
import Api.Request.VatRate
import Components.SimpleTable exposing (viewTable)
import Gen.Params.Enterprises.Id_ exposing (Params)
import Gen.Route
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Http
import Maybe
import Page
import Regex
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ req =
    Page.protected.element
        (\_ ->
            { init = init req
            , update = update
            , view = view
            , subscriptions = \_ -> Sub.none
            }
        )


init : Request.With Params -> ( Model, Cmd Msg )
init req =
    case req.params.id |> String.toInt of
        Just id ->
            ( { edited_enterprise_id = id
              , selectedTab = EnterpriseData
              , vatRates = []
              , comment = ""
              , vatRate = ""
              }
            , Api.Request.VatRate.getVatRatesVatrateGet 1 id |> Api.send ReceivedVatRates
            )

        Nothing ->
            ( { edited_enterprise_id = 0
              , selectedTab = EnterpriseData
              , vatRates = []
              , comment = ""
              , vatRate = ""
              }
            , Request.pushRoute
                Gen.Route.NotFound
                req
            )


type Tab
    = EnterpriseData
    | VatRates


type alias Model =
    { edited_enterprise_id : Int
    , selectedTab : Tab
    , vatRates : List Api.Data.VatRateResponse
    , comment : String
    , vatRate : String
    }


type Field
    = VatRate
    | Comment


type Msg
    = ClickedTab Tab
    | ReceivedVatRates (Result Http.Error (List Api.Data.VatRateResponse))
    | FilledField Field String
    | ClickedAddVatRate
    | ReceivedAddVatRateResponse (Result Http.Error Api.Data.VatRateResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedTab tab ->
            ( { model | selectedTab = tab }, Cmd.none )

        ReceivedVatRates response ->
            case response of
                Ok vatrates ->
                    ( { model | vatRates = vatrates }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        FilledField field inputString ->
            case field of
                Comment ->
                    ( { model | comment = inputString }, Cmd.none )

                VatRate ->
                    ( { model
                        | vatRate =
                            (Regex.fromString "\\d+\\.?\\d*"
                                |> Maybe.withDefault Regex.never
                                |> Regex.find
                            )
                                inputString
                                |> List.head
                                |> Maybe.withDefault
                                    { match = "", index = 0, number = 0, submatches = [] }
                                |> .match
                      }
                    , Cmd.none
                    )

        ClickedAddVatRate ->
            ( model
            , Api.Request.VatRate.addVatrateVatratePost
                { vatRate = model.vatRate |> String.toFloat |> Maybe.withDefault 0
                , comment = model.comment
                , enterpriseId = model.edited_enterprise_id
                }
                |> Api.send ReceivedAddVatRateResponse
            )

        ReceivedAddVatRateResponse _ ->
            ( model
            , Api.Request.VatRate.getVatRatesVatrateGet 1 model.edited_enterprise_id |> Api.send ReceivedVatRates
            )


viewEditVatRates : Model -> List VatRateResponse -> Html Msg
viewEditVatRates model vatrates =
    div
        []
        [ viewTable
            [ ( "ID", .id >> String.fromInt >> text )
            , ( "Stawka VAT", .vatRate >> String.fromFloat >> text )
            , ( "Komentarz", .comment >> text )
            ]
            vatrates
        , h3 []
            [ text "Dodaj stawkę VAT" ]
        , form [ Events.onSubmit ClickedAddVatRate ]
            [ label [ Attr.for "vatrate" ] [ text "Stawka VAT" ]
            , br [] []
            , input
                [ Attr.id "vatrate"
                , Attr.type_ "text"
                , Attr.value model.vatRate
                , Events.onInput (FilledField VatRate)
                ]
                []
            , br [] []
            , label [ Attr.for "comment" ] [ text "Komentarz" ]
            , br [] []
            , input
                [ Attr.id "comment"
                , Attr.type_ "text"
                , Attr.value model.comment
                , Events.onInput (FilledField Comment)
                ]
                []
            , br [] []
            , button
                [ Attr.class "button primary"
                ]
                [ text "Dodaj stawkę" ]
            ]
        ]


view : Model -> View Msg
view model =
    { title = "Opcje firmy"
    , body =
        [ viewTabs
            [ TabData EnterpriseData "Dane firmy" (text "Jakis szajs")
            , TabData VatRates
                "Stawki VAT"
                (viewEditVatRates model model.vatRates)
            ]
            model.selectedTab
        ]
    }


type alias TabData msg =
    { identifier : Tab
    , tabname : String
    , contents : Html msg
    }


viewTabs : List (TabData Msg) -> Tab -> Html Msg
viewTabs tabs activeTab =
    div []
        [ div [ Attr.class "tab-container" ]
            [ div [ Attr.class "tab-header-container" ]
                (List.map
                    (\t ->
                        button
                            [ Attr.classList
                                [ ( "active", t.identifier == activeTab )
                                , ( "tab", True )
                                ]
                            , Events.onClick (ClickedTab t.identifier)
                            ]
                            [ text t.tabname ]
                    )
                    (List.reverse tabs)
                )
            , div
                [ Attr.class "tab-content-container" ]
                [ tabs
                    |> List.filter (\t -> t.identifier == activeTab)
                    |> List.map .contents
                    |> List.head
                    |> Maybe.withDefault (text "")
                ]
            ]
        ]
