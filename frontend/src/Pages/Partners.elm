module Pages.Partners exposing (Model, Msg, page)

import Api
import Api.Data exposing (TradingPartnerResponse)
import Api.Request.TradingPartner
import Effect exposing (Effect)
import Gen.Route as Route
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Http
import Page
import Request exposing (Request)
import Shared
import User
import View exposing (View)


type alias Model =
    { partners : List TradingPartnerResponse
    }


type Msg
    = GotTradingPartnersResponse (Result Http.Error (List Api.Data.TradingPartnerResponse))


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\user ->
            { init = init user
            , update = update req
            , subscriptions = \_ -> Sub.none
            , view = view shared
            }
        )


init : User.User -> ( Model, Effect Msg )
init user =
    ( { partners = []
      }
    , Api.Request.TradingPartner.getTradingPartnersTradingPartnerGet 1 (user.favEnterpriseId |> Maybe.withDefault -1)
        |> Api.send GotTradingPartnersResponse
        |> Effect.fromCmd
    )


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        GotTradingPartnersResponse response ->
            case response of
                Ok partners ->
                    ( { model | partners = partners }, Effect.none )

                Err _ ->
                    ( model, Effect.none )


view : Shared.Model -> Model -> View Msg
view _ model =
    View
        "Partners"
        [ viewTable
            [ ( "ID", .id >> String.fromInt >> text )
            , ( "NIP", .nipNumber >> text )
            , ( "Nazwa", .name >> text )
            , ( "Adres", .address >> text )
            ]
            model.partners
        , a
            [ Attr.class "primary"
            , Route.Partners__Add |> Route.toHref |> Attr.href
            ]
            [ text "Dodaj kontrahenta" ]
        ]


viewTable : List ( String, a -> Html msg ) -> List a -> Html msg
viewTable table_columns data =
    table [ Attr.class "styled-table" ]
        [ thead []
            (List.map (\( name, _ ) -> th [] [ text name ]) table_columns)
        , tbody []
            (List.map
                (\row ->
                    tr []
                        (List.map
                            (\( _, getter ) -> td [] [ getter row ])
                            table_columns
                        )
                )
                data
            )
        ]
