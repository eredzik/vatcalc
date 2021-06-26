module Pages.Enterprises exposing (Model, Msg, page)

import Api.Enterprise exposing (Enterprise)
import Components.SimpleTable exposing (simpleBootstrapTable)
import Gen.Route as Route
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.element
        (\_ ->
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { enterprises : List Enterprise }


init : ( Model, Cmd Msg )
init =
    ( Model [], Cmd.none )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
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
            if List.length model.enterprises > 0 then
                div []
                    [ div [] [ text "Firmy przypisane do twojego konta" ]
                    , div []
                        [ simpleBootstrapTable
                            [ ( "ID", True, .id )
                            , ( "Numer NIP", False, .nip_number )
                            , ( "Nazwa", False, .name )
                            ]
                            model.enterprises
                        ]
                    ]

            else
                text "Nie masz żadnej firmy przypisanej do konta."
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
