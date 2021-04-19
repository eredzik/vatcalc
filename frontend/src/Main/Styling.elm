module Main.Styling exposing (..)

import Element
import Element.Font


blue : Element.Color
blue =
    Element.rgba255 62 84 229 1


blue2 : Element.Color
blue2 =
    Element.rgba255 90 62 229 1


lblue : Element.Color
lblue =
    Element.rgba255 197 247 240 0.8


vlblue : Element.Color
vlblue =
    Element.rgba 62 229 229 1


font : Element.Attribute msg
font =
    Element.Font.family
        [ Element.Font.typeface " -apple-system"
        , Element.Font.typeface "BlinkMacSystemFont"
        , Element.Font.typeface "Segoe UI"
        , Element.Font.typeface "Roboto"
        , Element.Font.typeface "Helvetica"
        , Element.Font.typeface "Arial"
        , Element.Font.typeface "sans-serif"
        , Element.Font.typeface "Apple Color Emoji"
        , Element.Font.typeface "Segoe UI Emoji"
        , Element.Font.typeface "Segoe UI Symbol"
        ]
