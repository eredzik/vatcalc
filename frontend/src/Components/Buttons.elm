module Components.Buttons exposing (..)

import Browser.Events exposing (onClick)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onSubmit)
import Svg.Styled.Attributes exposing (class)


primaryButton : String -> msg -> Html msg
primaryButton button_text msg_to_send =
    button [ class "primary-button", onSubmit msg_to_send ] [ text button_text ]


secondaryButton : String -> msg -> Html msg
secondaryButton button_text msg_to_send =
    button [ class "secondary-button", onSubmit msg_to_send ] [ text button_text ]
