port module Storage exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import User exposing (User, decodeUser, encodeUser)


type alias Storage =
    { user : Maybe User }


fromJson : Decode.Value -> Storage
fromJson json =
    json
        |> Decode.decodeValue decoder
        |> Result.withDefault init


init : Storage
init =
    { user = Nothing
    }


decoder : Decode.Decoder Storage
decoder =
    Decode.map Storage
        (Decode.field "user" (Decode.maybe decodeUser))


save : Storage -> Decode.Value
save storage =
    Encode.object
        [ ( "user"
          , storage.user
                |> Maybe.map encodeUser
                |> Maybe.withDefault Encode.null
          )
        ]



-- UPDATING STORAGE


signIn : User -> Storage -> Cmd msg
signIn user storage =
    saveToLocalStorage { storage | user = Just user }


signOut : Storage -> Cmd msg
signOut storage =
    saveToLocalStorage { storage | user = Nothing }



-- PORTS


saveToLocalStorage : Storage -> Cmd msg
saveToLocalStorage =
    save >> save_


port save_ : Decode.Value -> Cmd msg


load : (Storage -> msg) -> Sub msg
load fromStorage =
    load_ (fromJson >> fromStorage)


port load_ : (Decode.Value -> msg) -> Sub msg
