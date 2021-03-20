module Route exposing (..)

import Browser.Navigation
import Html
import Html.Attributes
import Url
import Url.Parser


type Route
    = TradePartner
    | Invoices


parser : Url.Parser.Parser (Route -> a) a
parser =
    Url.Parser.oneOf
        [ Url.Parser.map TradePartner Url.Parser.top
        , Url.Parser.map TradePartner (Url.Parser.s "tradepartners")
        , Url.Parser.map Invoices (Url.Parser.s "invoices")
        ]


href : Route -> Html.Attribute msg
href targetRoute =
    Html.Attributes.href (routeToString targetRoute)


fromUrl : Url.Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Url.Parser.parse parser


replaceUrl : Browser.Navigation.Key -> Route -> Cmd msg
replaceUrl key route =
    Browser.Navigation.replaceUrl key (routeToString route)


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                TradePartner ->
                    [ "tradepartners" ]

                Invoices ->
                    [ "invoices" ]
    in
    "#/" ++ String.join "/" pieces
