module Main exposing (main)

import Browser
import Main.Functions exposing (init, update, view)
import Main.Types exposing (Flags, Model, Msg(..))


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }
