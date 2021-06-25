module Api.Token exposing
    ( Token(..)
    , decoder, encode
    )

{-|

@docs Token
@docs decoder, encode
@docs get, put, post, delete

-}

import Json.Decode as Json
import Json.Encode as Encode


type Token
    = Token String


decoder : Json.Decoder Token
decoder =
    Json.map Token Json.string


encode : Token -> Json.Value
encode (Token token) =
    Encode.string token



-- HTTP HELPERS
