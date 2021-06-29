module Api.User exposing
    ( User
    , decoder, encode
    , authentication, registration
    , emptyUser
    )

{-|

@docs User
@docs decoder, encode

@docs authentication, registration, current, update

-}

import Api.Data exposing (Data)
import Api.Enterprise exposing (Enterprise)
import Api.Token exposing (Token(..))
import Http exposing (stringBody)
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Url exposing (percentEncode)


type alias User =
    { email : String
    , token : Token
    , selectedEnterprise : Maybe Enterprise
    }


emptyUser : User
emptyUser =
    User ""
        (Token "")
        Nothing


decoder : Decoder User
decoder =
    Decode.succeed User
        |> required "email" Decode.string
        |> required "token" Api.Token.decoder
        |> optional "selectedEnterprise" (Decode.map Just Api.Enterprise.decode) Nothing


encode : User -> Encode.Value
encode user =
    let
        enterprise_encoder =
            case user.selectedEnterprise of
                Just enterprise ->
                    [ ( "selectedEnterprise", Api.Enterprise.encode enterprise ) ]

                Nothing ->
                    []
    in
    Encode.object
        ([ ( "email", Encode.string user.email )
         , ( "token", Api.Token.encode user.token )
         ]
            ++ enterprise_encoder
        )


authentication :
    { user : { user | email : String, password : String }
    , onResponse : Data String -> msg
    }
    -> Cmd msg
authentication options =
    let
        body : Http.Body
        body =
            stringBody "application/x-www-form-urlencoded"
                (percentEncode "username"
                    ++ "="
                    ++ percentEncode options.user.email
                    ++ "&"
                    ++ percentEncode "password"
                    ++ "="
                    ++ percentEncode options.user.password
                )
    in
    Http.post
        { url = "api/auth/login"
        , body = body
        , expect =
            Api.Data.expectJson options.onResponse loginDecoder
        }


loginDecoder : Decoder String
loginDecoder =
    Decode.field "access_token" string


registration :
    { user :
        { user
            | username : String
            , email : String
            , password : String
        }
    , onResponse : Data String -> msg
    }
    -> Cmd msg
registration options =
    let
        body : Encode.Value
        body =
            Encode.object
                [ ( "email", Encode.string options.user.email )
                , ( "password", Encode.string options.user.password )
                ]
    in
    Http.post
        { url = "api/auth/register"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse registerResponseDecoder
        }


registerResponseDecoder : Decoder String
registerResponseDecoder =
    Decode.field "id" string
