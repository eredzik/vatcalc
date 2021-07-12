module Components.Form exposing (Field, viewField, viewForm)

import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events


type alias Field msg =
    { label : String
    , type_ : String
    , value : String
    , onInput : String -> msg
    , onBlur : msg
    }


viewField : Field msg -> Html msg
viewField options =
    fieldset [ Attr.class "form-group" ]
        [ label [] [ text (options.label ++ ": ") ]
        , input
            [ Attr.class "form-control form-control-lg"
            , Attr.placeholder options.label
            , Attr.type_ options.type_
            , Attr.value options.value
            , Events.onInput options.onInput
            , Events.onBlur options.onBlur
            ]
            []
        ]


viewForm : List (Field msg) -> String -> msg -> Html msg
viewForm fields button_label onSubmitMsg =
    form [ Events.onSubmit onSubmitMsg ] <|
        List.map viewField fields
            ++ [ button [] [ text button_label ] ]
