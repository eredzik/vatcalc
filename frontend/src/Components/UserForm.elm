module Components.UserForm exposing (Field, view)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.ErrorList
import Gen.Route as Route exposing (Route)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (class, href, placeholder, type_, value)
import Html.Styled.Events as Events


type alias Field msg =
    { label : String
    , type_ : String
    , value : String
    , onInput : String -> msg
    }


view :
    { user : Data User
    , label : String
    , onFormSubmit : msg
    , alternateLink : { label : String, route : Route }
    , fields : List (Field msg)
    }
    -> Html msg
view options =
    div []
        [ div []
            [ div []
                [ div []
                    [ h1 [] [ text options.label ]
                    , p []
                        [ a [ href (Route.toHref options.alternateLink.route) ]
                            [ text options.alternateLink.label ]
                        ]
                    , case options.user of
                        Api.Data.Failure reasons ->
                            Components.ErrorList.view reasons

                        _ ->
                            text ""
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
    fieldset [ class "form-group" ]
        [ label [] [ text (options.label ++ ": ") ]
        , input
            [ class "form-control form-control-lg"
            , placeholder options.label
            , type_ options.type_
            , value options.value
            , Events.onInput options.onInput
            ]
            []
        ]
