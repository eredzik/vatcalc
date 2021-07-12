module Components.UserForm exposing (view)

-- import Api.xxData exposing (Data)
-- import Api.User exposing (User)

import Components.Form exposing (Field, viewField)
import Gen.Route as Route exposing (Route)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (href)
import Html.Styled.Events as Events


view :
    { label : String
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
                    , form [ Events.onSubmit options.onFormSubmit ] <|
                        List.concat
                            [ List.map viewField options.fields
                            , [ button [] [ text options.label ] ]
                            ]
                    ]
                ]
            ]
        ]
