module Pages.Enterprises exposing (Model, Msg, page)

import Api
import Api.Data exposing (EnterpriseResponse, UserEnterpriseRoles(..))
import Api.Request.Enterprise
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
    Page.protected.element
        (\_ ->
            { init = init shared
            , update = update shared
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { enterprises : List EnterpriseResponse }


init : Shared.Model -> ( Model, Cmd Msg )
init _ =
    ( { enterprises = [] }
    , Api.Request.Enterprise.getUserEnterprisesEnterpriseGet 1
        |> Api.send GotEnterprisesData
    )



-- UPDATE


type Msg
    = GotEnterprisesData (Result Http.Error (List EnterpriseResponse))
    | ClickedSelectEnterprise Int


update : Shared.Model -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        GotEnterprisesData data ->
            case data of
                Ok enterprises ->
                    ( { model | enterprises = enterprises }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ClickedSelectEnterprise _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    let
        table =
            div []
                [ div [] [ text "Firmy przypisane do twojego konta" ]
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
                                i
                                    [ Attr.class "fas fa-angle-double-right fa-lg"
                                    , Attr.class "clickable"
                                    , Events.onClick (ClickedSelectEnterprise row.enterpriseId)
                                    ]
                                    [ text "" ]
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
            [ tr [] (List.map (\( _, getter ) -> td [] (List.map getter data)) table_columns)
            ]
        ]
