module User exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


type alias User =
    { email : String
    , username : String
    , favEnterpriseId : Maybe Int
    }


decodeUser : Decode.Decoder User
decodeUser =
    Decode.map3 User
        (Decode.field "email" Decode.string)
        (Decode.field "username" Decode.string)
        (Decode.maybe (Decode.field "favEnterpriseId" Decode.int))


encodeUser : User -> Decode.Value
encodeUser user =
    Encode.object
        ([ ( "username", Encode.string user.username )
         , ( "email", Encode.string user.email )
         ]
            ++ (case user.favEnterpriseId of
                    Just enterprise_id ->
                        [ ( "favEnterpriseId", enterprise_id |> Encode.int ) ]

                    Nothing ->
                        []
               )
        )
