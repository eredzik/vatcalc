module Pages.Enterprises exposing (Model, Msg, page)

import Api
import Api.Data exposing (EnterpriseResponse, UserEnterpriseRoles(..))
import Api.Request.Enterprise
import Components.SimpleTable exposing (simpleBootstrapTable)
import Gen.Route as Route
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Http
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.protected.element
        (\user ->
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
init shared =
    ( { enterprises = [] }
    , Api.Request.Enterprise.getUserEnterprisesEnterpriseGet 1
        |> Api.send GotEnterprisesData
    )



-- UPDATE


type Msg
    = GotEnterprisesData (Result Http.Error (List EnterpriseResponse))


update : Shared.Model -> Msg -> Model -> ( Model, Cmd Msg )
update shared msg model =
    case msg of
        GotEnterprisesData data ->
            case data of
                Ok enterprises ->
                    ( { model | enterprises = enterprises }, Cmd.none )

                Err err ->
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
                    [ simpleBootstrapTable
                        [ ( "ID", True, .enterpriseId >> String.fromInt )
                        , ( "Numer NIP", False, .nipNumber )
                        , ( "Nazwa", False, .name )
                        , ( "Adres", False, .address )
                        , ( "Rola"
                          , False
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
                    [ Attr.classList [ ( "btn", True ), ( "btn-primary", True ) ]
                    , Attr.href <| Route.toHref Route.Enterprises__Add
                    ]
                    [ text "Stwórz firmę" ]
                ]
            ]
        ]
    }
