module Pages.Enterprises exposing (Model, Msg, page)

import Api
import Api.Data exposing (EnterpriseResponse, UserEnterpriseRoles(..))
import Api.Request.Enterprise
import Api.Request.User
import Components.SimpleTable exposing (viewTable)
import Effect exposing (Effect)
import Gen.Route as Route
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Http
import Page
import Request exposing (Request)
import Shared
import User
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.advanced
        (\user ->
            { init = init
            , update = update
            , view = view user
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { enterprises : List EnterpriseResponse
    }


init : ( Model, Effect Msg )
init =
    ( { enterprises = [] }
    , Api.Request.Enterprise.getUserEnterprisesEnterpriseGet 1
        |> Api.send GotEnterprisesData
        |> Effect.fromCmd
    )



-- UPDATE


type Msg
    = GotEnterprisesData (Result Http.Error (List EnterpriseResponse))
    | ClickedSelectEnterprise Int
    | GotSelectEnterpriseResponse (Result Http.Error Api.Data.UserUpdateEnterpriseResponse)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotEnterprisesData data ->
            case data of
                Ok enterprises ->
                    ( { model | enterprises = enterprises }, Effect.none )

                Err _ ->
                    ( model, Effect.none )

        ClickedSelectEnterprise selected_id ->
            ( model
            , Api.Request.User.updateEnterpriseUserMePreferredEnterprisePatch selected_id
                |> Api.send GotSelectEnterpriseResponse
                |> Effect.fromCmd
            )

        GotSelectEnterpriseResponse response ->
            ( model
            , case response of
                Ok user ->
                    Just user.favEnterpriseId
                        |> Shared.SelectedFavouriteEnterprise
                        |> Effect.fromShared

                Err _ ->
                    Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : User.User -> Model -> View Msg
view user model =
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
                                    (user.favEnterpriseId |> Maybe.withDefault -1)
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
                    [ Attr.classList [ ( "primary", True ), ( "button", True ) ]
                    , Attr.href <| Route.toHref Route.Enterprises__Add
                    ]
                    [ text "Stwórz firmę" ]
                ]
            ]
        ]
    }
