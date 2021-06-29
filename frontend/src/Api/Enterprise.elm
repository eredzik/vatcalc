module Api.Enterprise exposing (..)

import Json.Decode as Json
import Json.Encode as Encode


type alias Enterprise =
    { id : String
    , nip_number : String
    , name : String
    }


decode : Json.Decoder Enterprise
decode =
    Json.map3 Enterprise
        (Json.field "id" Json.string)
        (Json.field "nip_number" Json.string)
        (Json.field "name" Json.string)


encode : Enterprise -> Encode.Value
encode enterprise =
    Encode.object
        [ ( "id", Encode.string enterprise.id )
        , ( "nip_number", Encode.string enterprise.nip_number )
        , ( "name", Encode.string enterprise.name )
        ]



-- create :
--     { data :
--         { nip_number : String
--         , name : String
--         }
--     , onResponse : Data String -> msg
--     }
--     -> Cmd msg
-- create options =
--     let
--         body : Encode.Value
--         body =
--             Encode.object
--                 [ ( "nip_number", Encode.string options.data.nip_number )
--                 , ( "name", Encode.string options.data.name )
--                 ]
--     in
--     Http.post
--         { url = "api/auth/register"
--         , body = Http.jsonBody body
--         , expect =
--             Api.Data.expectJson options.onResponse registerResponseDecoder
--         }
