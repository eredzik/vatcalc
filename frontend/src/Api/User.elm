module Api.User exposing
    ( User
    , decoder, encode
    , authentication, registration, update
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
import Json.Decode as Json
import Json.Encode as Encode
import Url exposing (percentEncode)


type alias User =
    { email : String
    , token : Token
    , selectedEnterprise : Maybe Enterprise
    }


emptyUser : User
emptyUser =
    User "" (Token "") Nothing


decoder : Json.Decoder User
decoder =
    Json.map3 User
        (Json.field "email" Json.string)
        (Json.field "token" Api.Token.decoder)
        (Json.field "selectedEnterprise" Api.Enterprise.decoder)


encode : User -> Json.Value
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


loginDecoder : Json.Decoder String
loginDecoder =
    Json.field "access_token" Json.string


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
        body : Json.Value
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


registerResponseDecoder : Json.Decoder String
registerResponseDecoder =
    Json.field "id" Json.string


update :
    { token : Token
    , user :
        { user
            | username : String
            , email : String
            , password : Maybe String
            , image : String
            , bio : String
        }
    , onResponse : Data User -> msg
    }
    -> Cmd msg
update options =
    let
        body : Json.Value
        body =
            Encode.object
                [ ( "user"
                  , Encode.object
                        (List.concat
                            [ [ ( "username", Encode.string options.user.username )
                              , ( "email", Encode.string options.user.email )
                              , ( "image", Encode.string options.user.image )
                              , ( "bio", Encode.string options.user.bio )
                              ]
                            , case options.user.password of
                                Just password ->
                                    [ ( "password", Encode.string password ) ]

                                Nothing ->
                                    []
                            ]
                        )
                  )
                ]
    in
    Api.Token.put (Just options.token)
        { url = "https://conduit.productionready.io/api/user"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "user" decoder)
        }
