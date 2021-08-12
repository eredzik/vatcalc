module Pages.Enterprises.Id_ exposing (Model, Msg, page)

import Gen.Params.Enterprises.Id_ exposing (Params)
import Gen.Route
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Maybe
import Page
import Request exposing (Request)
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
              , tabs =
                    [ Tab True "Opcje" (text "Jakis szajs")
                    , Tab False "Stawki VAT" (text "Jakis szajs")
                    ]
              }
            , Cmd.none
            )

        Nothing ->
            ( { edited_enterprise_id = 0
              , tabs = []
              }
            , Request.pushRoute
                Gen.Route.NotFound
                req
            )


type alias Model =
    { edited_enterprise_id : Int, tabs : List (Tab Msg) }


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> View Msg
view model =
    { title = "Opcje firmy"
    , body =
        [ viewTabs
            model.tabs
        ]
    }


type alias Tab msg =
    { is_active : Bool
    , tabname : String
    , contents : Html msg
    }


viewTabs : List (Tab msg) -> Html msg
viewTabs tabs =
    div []
        [ div [ Attr.class "tab" ]
            (List.map
                (\t -> button [ Attr.classList [ ( "active", t.is_active ) ] ] [ text t.tabname ])
                tabs
            )
        , div
            []
            [ List.filter .is_active tabs
                |> List.map .contents
                |> List.head
                |> Maybe.withDefault (text "")
            ]
        ]
