module Components.NotFound exposing (view)

import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (href)


view : Html msg
view =
    div []
        [ h2 [] [ text "Page not found." ]
        , h5 []
            [ text "But here's the "
            , a [ href "/" ] [ text "homepage" ]
            , text "!"
            ]
        ]
