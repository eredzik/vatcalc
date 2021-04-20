module Main exposing (main)

import Browser
import Main.Functions exposing (Model, init, update, view)
import Main.Types exposing (Msg(..))


main : Program {} Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }
