module Pages.Enterprises exposing (Model, Msg, page)

import Api
import Api.Data exposing (EnterpriseResponse, UserEnterpriseRoles(..))
import Api.Request.Enterprise
import Effect exposing (Effect)
import Gen.Route as Route
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Http
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.protected.advanced
        (\_ ->
            { init = init shared
            , update = update shared
            , view = view shared
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { enterprises : List EnterpriseResponse
    }


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { enterprises = [] }
    , Api.Request.Enterprise.getUserEnterprisesEnterpriseGet 1
        |> Api.send GotEnterprisesData
        |> Effect.fromCmd
    )



-- UPDATE


type Msg
    = GotEnterprisesData (Result Http.Error (List EnterpriseResponse))
    | ClickedSelectEnterprise Int


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        GotEnterprisesData data ->
            case data of
                Ok enterprises ->
                    ( { model | enterprises = enterprises }, Effect.none )

                Err _ ->
                    ( model, Effect.none )

        ClickedSelectEnterprise selected_id ->
            ( model
            , Just selected_id
                |> Shared.SelectedFavouriteEnterprise
                |> Effect.fromShared
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    let
        table =
            div []
                [ h1 [] [ text "Firmy przypisane do twojego konta" ]
                , div []
                    [ viewTable
                        [ ( "ID", .enterpriseId >> String.fromInt >> text )
                        , ( "Numer NIP", .nipNumber >> text )
                        , ( "Nazwa", .name >> text )
                        , ( "Adres", .address >> text )
                        , ( "Rola"
                          , .role
                                >> (\role ->
                                        case role of
                                            UserEnterpriseRolesADMIN ->
                                                "Administrator"

                                            UserEnterpriseRolesEDITOR ->
                                                "Edytor"

                                            UserEnterpriseRolesVIEWER ->
                                                "Oglądający"
                                   )
                                >> text
                          )
                        , ( "Aktywuj"
                          , \row ->
                                if
                                    (shared.selectedEnterpriseId |> Maybe.withDefault -1)
                                        == row.enterpriseId
                                then
                                    text ""

                                else
                                    i
                                        [ Attr.class "fas fa-angle-double-right fa-lg"
                                        , Attr.class "clickable"
                                        , Events.onClick (ClickedSelectEnterprise row.enterpriseId)
                                        ]
                                        [ text "" ]
                          )
                        , ( "Opcje"
                          , \row ->
                                a
                                    [ Route.Enterprises__Id_ { id = String.fromInt row.enterpriseId }
                                        |> Route.toHref
                                        |> Attr.href
                                    ]
                                    [ i
                                        [ Attr.class "fas fa-cog fa-lg"
                                        ]
                                        [ text "" ]
                                    ]
                          )
                        ]
                        model.enterprises
                    ]
                ]
    in
    { title = "Firmy"
    , body =
        [ div []
            [ table
            , div []
                [ a
                    [ Attr.classList [ ( "button-primary", True ) ]
                    , Attr.href <| Route.toHref Route.Enterprises__Add
                    ]
                    [ text "Stwórz firmę" ]
                ]
            ]
        ]
    }


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
