module Components.Navbar exposing (view)

import Gen.Route as Route exposing (Route)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events


view :
    { isLoggedIn : Bool
    , currentRoute : Route
    , onSignOut : msg
    }
    -> Html msg
view options =
    nav
        []
        [ a
            [ Attr.href <| Route.toHref Route.Home_ ]
            [ text "VatCalc" ]
        , ul
            []
            ([]
                ++ (if options.isLoggedIn then
                        [ a [ hrefAttrib Route.Invoices ] [ text "Rejestr VAT" ]
                        , a [ hrefAttrib Route.Partners ] [ text "Rejestr Kontrahentów" ]
                        , a [ hrefAttrib Route.Enterprises ] [ text "Rejestr Firm" ]
                        , a [ Events.onClick options.onSignOut ] [ text "Wyloguj się" ]
                        ]

                    else
                        [ a [ hrefAttrib Route.Login ] [ text "Zaloguj się" ]
                        , a [ hrefAttrib Route.Register ] [ text "Zarejestruj się" ]
                        ]
                   )
            )
        ]


hrefAttrib : Route -> Html.Styled.Attribute msg
hrefAttrib route =
    Attr.href <| Route.toHref route
