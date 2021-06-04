module Components.ErrorList exposing (view)

import Css
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr


view : List String -> Html msg
view reasons =
    if List.isEmpty reasons then
        text ""

    else
        ul []
            (List.map (\message -> li [ Attr.css [ Css.fontWeight Css.bold ] ] [ text <| messageToInfo message ]) reasons)


messageToInfo : String -> String
messageToInfo message =
    if message == "value_error.email" then
        "Email value is not valid"

    else if message == "REGISTER_USER_ALREADY_EXISTS" then
        "Supplied email is taken"

    else
        message
