module Components.Form exposing (Field, createForm, viewField)

import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events


type alias Field msg =
    { label : String
    , type_ : String
    , value : String
    , onInput : String -> msg
    }


createForm :
    { label : String
    , onFormSubmit : msg
    , fields : List (Field msg)
    }
    -> Html msg
createForm options =
    div []
        [ div []
            [ div []
                [ div []
                    [ h1 [] [ text options.label ]
                    , form [ Events.onSubmit options.onFormSubmit ] <|
                        List.concat
                            [ List.map viewField options.fields
                            , [ button [] [ text options.label ] ]
                            ]
                    ]
                ]
            ]
        ]


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
            ]
            []
        ]
