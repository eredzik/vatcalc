module Pages.NotFound exposing (view)

import Components.NotFound
import Html.Styled as Html exposing (..)


view : { title : String, body : List (Html msg) }
view =
    { title = "404"
    , body =
        [ Components.NotFound.view
        ]
    }
