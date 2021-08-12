module User exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


type alias User =
    { email : String
    , username : String
    }


decodeUser : Decode.Decoder User
decodeUser =
    Decode.map2 User
        (Decode.field "username" Decode.string)
        (Decode.field "email" Decode.string)


encodeUser : User -> Decode.Value
encodeUser user =
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "email", Encode.string user.email )
        ]
