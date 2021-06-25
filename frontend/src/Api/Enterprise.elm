module Api.Enterprise exposing (..)

import Json.Decode as Json
import Json.Encode as Encode


type alias Enterprise =
    { id : String
    , nip_number : String
    , name : String
    }


decoder : Json.Decoder (Maybe Enterprise)
decoder =
    Json.maybe
        (Json.map3 Enterprise
            (Json.field "id" Json.string)
            (Json.field "nip_number" Json.string)
            (Json.field "name" Json.string)
        )


encode : Enterprise -> Encode.Value
encode enterprise =
    Encode.object
        [ ( "id", Encode.string enterprise.id )
        , ( "nip_number", Encode.string enterprise.nip_number )
        , ( "name", Encode.string enterprise.name )
        ]
