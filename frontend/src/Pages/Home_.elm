module Pages.Home_ exposing (Model, Msg, page)

import Html.Styled as Html exposing (..)
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.element
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { content : List String
    }


init : Shared.Model -> ( Model, Cmd Msg )
init _ =
    ( { content = [ "Strona glowna" ] }
    , Cmd.none
    )


type Msg
    = Placeholder


update : Shared.Model -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        Placeholder ->
            ( model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ model =
    { title = ""
    , body =
        List.map text model.content
    }
