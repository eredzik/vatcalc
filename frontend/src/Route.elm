module Route exposing (..)

import Browser.Navigation
import Html
import Html.Attributes
import Url
import Url.Parser


type Route
    = Index
    | TradePartner
    | Invoices
    | LogIn
    | LogOut


parser : Url.Parser.Parser (Route -> a) a
parser =
    Url.Parser.oneOf
        [ Url.Parser.map TradePartner Url.Parser.top
        , Url.Parser.map TradePartner (Url.Parser.s "tradepartners")
        , Url.Parser.map Invoices (Url.Parser.s "invoices")
        , Url.Parser.map LogIn (Url.Parser.s "login")
        , Url.Parser.map LogOut (Url.Parser.s "logout")
        ]


href : Route -> Html.Attribute msg
href targetRoute =
    Html.Attributes.href (routeToString targetRoute)


fromUrl : Url.Url -> Route
fromUrl url =
    url
        |> Url.Parser.parse parser
        |> Maybe.withDefault Index


replaceUrl : Browser.Navigation.Key -> Route -> Cmd msg
replaceUrl key route =
    Browser.Navigation.replaceUrl key (routeToString route)


routeToString : Route -> String
routeToString page =
    case page of
        Index ->
            "/"

        TradePartner ->
            "/tradepartners"

        Invoices ->
            "invoices"

        LogIn ->
            "login"

        LogOut ->
            "logout"
