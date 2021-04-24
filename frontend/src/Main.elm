module Main exposing (main)

import Browser
import Main.Functions exposing (update, view)
import Main.Types exposing (Model, Msg(..), init)


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
