module Components.Navbar exposing (view)

-- import Html.Styled as Html exposing (..)
-- import Html.Styled.Attributes exposing (class, classList, css, href, src)
-- import Html.Styled.Events as Events

import Api.User exposing (User)
import Css
import Gen.Route as Route exposing (Route)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events


theme : { secondary : Css.Color, primary : Css.Color }
theme =
    { primary = Css.rgba 14 72 127 1
    , secondary = Css.rgba 255 240 138 1
    }


view :
    { user : Maybe User
    , currentRoute : Route
    , onSignOut : msg
    }
    -> Html msg
view model =
    nav
        [ Attr.css
            [ Css.displayFlex
            , Css.justifyContent Css.spaceBetween
            , Css.width <| Css.pct 100
            , Css.height <| Css.px 70
            , Css.backgroundColor theme.primary
            ]
        ]
        [ a
            [ Attr.href <| Route.toHref Route.Home_
            , Attr.css
                [ Css.alignItems Css.center
                , Css.displayFlex
                , Css.fontWeight Css.bold
                , Css.fontSize (Css.px 30)
                , Css.textDecoration Css.none
                , Css.paddingLeft <| Css.px 10
                , Css.color theme.secondary
                ]
            ]
            [ text "VatCalc" ]
        , ul
            [ Attr.css
                [ Css.displayFlex
                , Css.alignItems Css.center
                , Css.listStyleType Css.none
                ]
            ]
            ([]
                ++ (case model.user of
                        Just _ ->
                            [ viewLink ( "Strona główna", [ hrefAttrib Route.Home_ ] )
                            , viewLink ( "Wyloguj się", [ Events.onClick model.onSignOut ] )
                            ]

                        Nothing ->
                            [ viewLink ( "Zaloguj się", [ hrefAttrib Route.Login ] )
                            , viewLink ( "Zarejestruj się", [ hrefAttrib Route.Register ] )
                            ]
                   )
            )
        ]


hrefAttrib : Route -> Html.Styled.Attribute msg
hrefAttrib route =
    Attr.href <| Route.toHref route


viewLink : ( String, List (Html.Styled.Attribute msg) ) -> Html msg
viewLink ( label, action ) =
    let
        attributesDefault =
            action
                ++ [ Attr.css
                        [ Css.fontSize <| Css.px 25
                        , Css.padding <| Css.px 10
                        , Css.color <| theme.secondary
                        , Css.textDecoration Css.none
                        ]
                   ]
    in
    a
        attributesDefault
        [ text label ]



-- { url = Route.toHref route
-- , label = text label
-- }
